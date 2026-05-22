let lux = msg.payload.illuminance;
if (lux === undefined || lux === null) {
    return null;
}
lux = parseFloat(lux);
let buffer = flow.get("lux_buffer") || [];
let now = Date.now();
buffer.push({ time: now, value: lux });

// Keep last 5 minutes (300,000 ms)
buffer = buffer.filter(item => now - item.time <= 300000);
flow.set("lux_buffer", buffer);

// Calculate average
let sum = buffer.reduce((acc, val) => acc + val.value, 0);
let avg = sum / buffer.length;
flow.set("outdoor_lux_avg", avg);
global.set("outdoor_lux_avg", avg);

msg.payload = {
    lux: lux,
    avg: avg,
    buffer_size: buffer.length
};
return msg;
