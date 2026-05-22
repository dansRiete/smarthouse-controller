let states = flow.get("light_states");
if (!states) return null;

const nowStr = new Date().toISOString().replace('T', ' ').replace('Z', '');
let sqlTx = "BEGIN;\n";

const affected = ["LR-LUTV", "MB-LOB", "MB-LOTV", "TER-LIGHTS"];

for (let code of affected) {
    let light = states[code];
    if (!light) continue;
    
    light.state = "OFF";
    
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
    let wakeUp = new Date(now.getTime() + (targetEpoch - new Date(now.toLocaleString("en-US", { timeZone: "America/New_York" })).getTime())).getTime();
    if (now.getTime() >= wakeUp) {
        wakeUp += 24 * 60 * 60 * 1000;
    }
    
    if (!light.locked || !light.lockedUntil || light.lockedUntil < wakeUp) {
        light.locked = true;
        light.lockedUntil = wakeUp;
        
        const lockedUntilSql = `'${new Date(wakeUp).toISOString().replace('T', ' ').replace('Z', '')}'`;
        sqlTx += `UPDATE main.appliance SET state = 'OFF', locked = true, locked_until_utc = ${lockedUntilSql} WHERE code = '${code}';\n`;
        const lockData = JSON.stringify({ until: new Date(wakeUp).toISOString(), rule: 1 }).replace(/'/g, "''");
        sqlTx += `INSERT INTO main.event (utc_time, type, device, data) VALUES ('${nowStr}', 'locked-until', '${code}', '${lockData}');\n`;
    } else {
        sqlTx += `UPDATE main.appliance SET state = 'OFF' WHERE code = '${code}';\n`;
        const preserveData = JSON.stringify({ existing: new Date(light.lockedUntil).toISOString(), attempted: new Date(wakeUp).toISOString() }).replace(/'/g, "''");
        sqlTx += `INSERT INTO main.event (utc_time, type, device, data) VALUES ('${nowStr}', 'lock.preserved', '${code}', '${preserveData}');\n`;
    }
    
    const switchData = JSON.stringify({ state: "OFF", source: "turn off hours setting" }).replace(/'/g, "''");
    sqlTx += `INSERT INTO main.event (utc_time, type, device, data) VALUES ('${nowStr}', 'switch', '${code}', '${switchData}');\n`;
    
    let topic = `zigbee2mqtt/${code}/set`;
    let mqttPayload = {};
    if (code === "LR-LUTV") {
        mqttPayload = { state: "on", brightness: 20 };
    } else {
        mqttPayload = { state: "off" };
    }
    
    node.send([ null, { topic: topic, payload: JSON.stringify(mqttPayload) } ]);
    if (code === "TER-LIGHTS") {
        node.send([ null, { topic: "zigbee2mqtt/WRKTABLE/set", payload: JSON.stringify(mqttPayload) } ]);
    }
}

const groupData = JSON.stringify({ hour: 22, appliances: affected }).replace(/'/g, "''");
sqlTx += `INSERT INTO main.event (utc_time, type, data) VALUES ('${nowStr}', 'group.ALGHTS.turn-off-hours.triggered', '${groupData}');\n`;

sqlTx += "COMMIT;";

flow.set("light_states", states);
node.send([ { payload: sqlTx }, null ]);
return null;
