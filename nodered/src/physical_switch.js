const topic = msg.topic;
const parts = topic.split("/");
const code = parts[1];
const payload = msg.payload;

if (!payload || !payload.state) return null;

const newState = payload.state.toUpperCase();
let states = flow.get("light_states");
if (!states) return null;

let light = states[code];
if (!light) return null;

if (light.lastCommandedState === newState) {
    light.state = newState;
    light.lastCommandedState = null;
    flow.set("light_states", states);
    return null;
}

const oldState = light.state;
const oldLocked = light.locked;
const oldLockedUntil = light.lockedUntil;

light.state = newState;

// Astro math calculations
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

function getWakeUpTime() {
    const now = new Date();
    const formatter = new Intl.DateTimeFormat('en-US', {
        timeZone: 'America/New_York',
        year: 'numeric', month: 'numeric', day: 'numeric',
        hour: 'numeric', minute: 'numeric', second: 'numeric',
        hour12: false, weekday: 'short'
    });
    
    const parts = formatter.formatToParts(now);
    const partMap = Object.fromEntries(parts.map(p => [p.type, p.value]));
    
    const weekday = partMap.weekday;
    const isWeekend = weekday === "Sat" || weekday === "Sun";
    
    const targetHour = isWeekend ? 8 : 6;
    const targetMinute = isWeekend ? 0 : 55;
    
    let targetDate = new Date(now.toLocaleString("en-US", { timeZone: "America/New_York" }));
    targetDate.setHours(targetHour, targetMinute, 0, 0);
    const targetEpoch = targetDate.getTime();
    
    let resultDate = new Date(now.getTime() + (targetEpoch - new Date(now.toLocaleString("en-US", { timeZone: "America/New_York" })).getTime()));
    
    if (now >= resultDate) {
        const nextDay = new Date(now.getTime() + 24 * 60 * 60 * 1000);
        const nextParts = formatter.formatToParts(nextDay);
        const nextPartMap = Object.fromEntries(nextParts.map(p => [p.type, p.value]));
        const nextWeekday = nextPartMap.weekday;
        const nextIsWeekend = nextWeekday === "Sat" || nextWeekday === "Sun";
        const nextHour = nextIsWeekend ? 8 : 6;
        const nextMinute = nextIsWeekend ? 0 : 55;
        
        let nextTargetDate = new Date(nextDay.toLocaleString("en-US", { timeZone: "America/New_York" }));
        nextTargetDate.setHours(nextHour, nextMinute, 0, 0);
        resultDate = new Date(nextDay.getTime() + (nextTargetDate.getTime() - new Date(nextDay.toLocaleString("en-US", { timeZone: "America/New_York" })).getTime()));
    }
    return resultDate;
}

const now = new Date();
const sunTimes = calculateSunTimes(now);
const isDark = now < sunTimes.sunrise || now > sunTimes.sunset;

let locked = light.locked;
let lockedUntil = light.lockedUntil;
let rule = 0;
let lockChanged = false;

if (isDark) {
    if (newState === "OFF") {
        const wakeUp = getWakeUpTime().getTime();
        if (!locked || !lockedUntil || lockedUntil < wakeUp) {
            locked = true;
            lockedUntil = wakeUp;
            lockChanged = true;
            rule = 1;
        }
    } else {
        if (locked) {
            locked = false;
            lockedUntil = null;
            lockChanged = true;
            rule = 2;
        }
    }
} else {
    if (newState === "OFF") {
        if (locked) {
            locked = false;
            lockedUntil = null;
            lockChanged = true;
            rule = 4;
        }
    } else {
        locked = true;
        const sunsetPlus1 = new Date(sunTimes.sunset.getTime() + 60*60*1000).getTime();
        lockedUntil = sunsetPlus1;
        lockChanged = true;
        rule = 4;
    }
}

if (locked !== oldLocked || lockedUntil !== oldLockedUntil) {
    lockChanged = true;
}

light.locked = locked;
light.lockedUntil = lockedUntil;
flow.set("light_states", states);

// SQL update and event logging
const nowStr = new Date().toISOString().replace('T', ' ').replace('Z', '');
const lockedUntilSql = lockedUntil ? `'${new Date(lockedUntil).toISOString().replace('T', ' ').replace('Z', '')}'` : 'NULL';

let sqlTx = `BEGIN;\nUPDATE main.appliance SET state = '${newState}', locked = ${locked}, locked_until_utc = ${lockedUntilSql} WHERE code = '${code}';\n`;

const switchData = JSON.stringify({ state: newState, source: topic }).replace(/'/g, "''");
sqlTx += `INSERT INTO main.event (utc_time, type, device, mqtt_topic, data) VALUES ('${nowStr}', 'switch', '${code}', '${topic}', '${switchData}');\n`;

if (lockChanged) {
    if (locked) {
        const lockData = JSON.stringify({ until: new Date(lockedUntil).toISOString(), rule: rule }).replace(/'/g, "''");
        sqlTx += `INSERT INTO main.event (utc_time, type, device, data) VALUES ('${nowStr}', 'locked-until', '${code}', '${lockData}');\n`;
    } else {
        const unlockData = JSON.stringify({ rule: rule }).replace(/'/g, "''");
        sqlTx += `INSERT INTO main.event (utc_time, type, device, data) VALUES ('${nowStr}', 'unlocked', '${code}', '${unlockData}');\n`;
    }
}
sqlTx += "COMMIT;";

// Format dynamic MQTT set
const lightConfigs = {
    "LR-LUTV": { dimmable: true, powerSetting: null },
    "MB-LOB": { dimmable: true, powerSetting: 76 },
    "MB-LOTV": { dimmable: true, powerSetting: 76 },
    "TER-LIGHTS": { dimmable: false, powerSetting: null }
};
const cfg = lightConfigs[code];
let mqttMsgs = [];
let setTopic = `zigbee2mqtt/${code}/set`;
let mqttPayload = {};

const nowHour = new Date(new Date().toLocaleString("en-US", {timeZone: "America/New_York"})).getHours();

if (code === "LR-LUTV" && (nowHour < 7 || nowHour > 21)) {
    mqttPayload = {
        state: "on",
        brightness: (newState === "ON" ? 160 : 20)
    };
} else {
    if (newState === "ON") {
        mqttPayload.state = "on";
        if (cfg.dimmable) {
            mqttPayload.brightness = cfg.powerSetting ? Math.floor(255 * (cfg.powerSetting / 100)) : 160;
        }
    } else {
        mqttPayload.state = "off";
    }
}

mqttMsgs.push({ topic: setTopic, payload: JSON.stringify(mqttPayload) });
if (code === "TER-LIGHTS") {
    mqttMsgs.push({ topic: "zigbee2mqtt/WRKTABLE/set", payload: JSON.stringify(mqttPayload) });
}

node.send([ { payload: sqlTx }, null ]);
for (let m of mqttMsgs) {
    node.send([ null, m ]);
}
return null;
