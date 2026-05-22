const LAT = 25.76;
const LNG = -80.19;

function calculateSunTimes(date) {
    const radians = Math.PI / 180;
    const degrees = 180 / Math.PI;
    const start = new Date(date.getFullYear(), 0, 0);
    const diff = date - start;
    const oneDay = 1000 * 60 * 60 * 24;
    const day = Math.floor(diff / oneDay);
    const lngHour = LNG / 15;
    
    function getSunriseSunsetTime(isSunrise) {
        const t = day + ((isSunrise ? 6 : 18) - lngHour) / 24;
        const M = 0.9856 * t - 3.289;
        let L = M + 1.916 * Math.sin(M * radians) + 0.020 * Math.sin(2 * M * radians) + 282.634;
        L = (L + 360) % 360;
        let RA = degrees * Math.atan(0.91764 * Math.tan(L * radians));
        RA = (RA + 360) % 360;
        const Lquadrant = Math.floor(L / 90) * 90;
        const RAquadrant = Math.floor(RA / 90) * 90;
        RA = RA + (Lquadrant - RAquadrant);
        RA = RA / 15;
        const sinDec = 0.39782 * Math.sin(L * radians);
        const cosDec = Math.cos(Math.asin(sinDec));
        const zenith = 90.8333;
        const cosH = (Math.cos(zenith * radians) - sinDec * Math.sin(LAT * radians)) / (cosDec * Math.cos(LAT * radians));
        if (cosH > 1 || cosH < -1) return null;
        const H = (isSunrise ? 360 - degrees * Math.acos(cosH) : degrees * Math.acos(cosH)) / 15;
        const T = H + RA - 0.06571 * t - 6.622;
        let UT = T - lngHour;
        UT = (UT + 24) % 24;
        const utDate = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0));
        utDate.setUTCHours(Math.floor(UT));
        utDate.setUTCMinutes(Math.floor((UT % 1) * 60));
        utDate.setUTCSeconds(Math.floor((((UT % 1) * 60) % 1) * 60));
        return utDate;
    }
    return { sunrise: getSunriseSunsetTime(true), sunset: getSunriseSunsetTime(false) };
}

let states = flow.get("light_states");
if (!states) return null;

const avgLux = flow.get("outdoor_lux_avg");
const now = Date.now();
const nowStr = new Date().toISOString().replace('T', ' ').replace('Z', '');
let sqlTx = "BEGIN;\n";
let hasSql = false;
let mqttMsgs = [];

const lightConfigs = {
    "LR-LUTV": { setting: 74.75, dimmable: true, powerSetting: null },
    "MB-LOB": { setting: 75.0, dimmable: true, powerSetting: 76 },
    "MB-LOTV": { setting: 75.0, dimmable: true, powerSetting: 76 },
    "TER-LIGHTS": { setting: 75.0, dimmable: false, powerSetting: null }
};

for (let code of Object.keys(lightConfigs)) {
    let light = states[code];
    if (!light) continue;
    
    // 1. Check lock expiry
    if (light.locked && light.lockedUntil && now > light.lockedUntil) {
        const wasLockedUntilStr = new Date(light.lockedUntil).toISOString();
        light.locked = false;
        light.lockedUntil = null;
        
        sqlTx += `UPDATE main.appliance SET locked = false, locked_until_utc = NULL WHERE code = '${code}';\n`;
        const expiredData = JSON.stringify({ wasLockedUntil: wasLockedUntilStr }).replace(/'/g, "''");
        sqlTx += `INSERT INTO main.event (utc_time, type, device, data) VALUES ('${nowStr}', 'lock.expired', '${code}', '${expiredData}');\n`;
        hasSql = true;
    }
    
    // 2. Automated Lux Control
    if (!light.locked && avgLux !== undefined && avgLux !== null) {
        const cfg = lightConfigs[code];
        const setting = cfg.setting;
        let decision = null;
        
        if (avgLux < setting - 25) {
            decision = "ON";
        } else if (avgLux > setting + 25) {
            decision = "OFF";
        }
        
        if (decision !== null) {
            const stateChanged = (light.state !== decision);
            const eventType = stateChanged ? "pwr-control.trigger" : "pwr-control.check";
            
            const pwrData = JSON.stringify({
                decision: decision.toLowerCase(),
                avg: parseFloat(avgLux.toFixed(2)),
                setting: setting,
                hysteresisOn: 25,
                hysteresisOff: 25
            }).replace(/'/g, "''");
            sqlTx += `INSERT INTO main.event (utc_time, type, device, data) VALUES ('${nowStr}', '${eventType}', '${code}', '${pwrData}');\n`;
            hasSql = true;
            
            if (stateChanged) {
                light.state = decision;
                light.lastCommandedState = decision;
                
                sqlTx += `UPDATE main.appliance SET state = '${decision}' WHERE code = '${code}';\n`;
                const switchData = JSON.stringify({ state: decision, source: "pwr-control" }).replace(/'/g, "''");
                sqlTx += `INSERT INTO main.event (utc_time, type, device, data) VALUES ('${nowStr}', 'switch', '${code}', '${switchData}');\n`;
                
                formatMqttMsg(code, decision);
            }
        }
    }
}

function formatMqttMsg(code, state) {
    const cfg = lightConfigs[code];
    let topic = `zigbee2mqtt/${code}/set`;
    let payload = {};
    
    // Server runs in America/New_York (formatter to get local hour)
    const nowHour = new Date(new Date().toLocaleString("en-US", {timeZone: "America/New_York"})).getHours();
    
    if (code === "LR-LUTV" && (nowHour < 7 || nowHour > 21)) {
        payload = {
            state: "on",
            brightness: (state === "ON" ? 160 : 20)
        };
    } else {
        if (state === "ON") {
            payload.state = "on";
            if (cfg.dimmable) {
                payload.brightness = cfg.powerSetting ? Math.floor(255 * (cfg.powerSetting / 100)) : 160;
            }
        } else {
            payload.state = "off";
        }
    }
    
    mqttMsgs.push({ topic: topic, payload: JSON.stringify(payload) });
    if (code === "TER-LIGHTS") {
        mqttMsgs.push({ topic: "zigbee2mqtt/WRKTABLE/set", payload: JSON.stringify(payload) });
    }
}

flow.set("light_states", states);

if (hasSql) {
    sqlTx += "COMMIT;";
    node.send([ { payload: sqlTx }, null ]);
}

if (mqttMsgs.length > 0) {
    for (let m of mqttMsgs) {
        node.send([ null, m ]);
    }
}
return null;
