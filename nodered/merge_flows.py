import json
import os

def merge():
    # Resolve relative paths relative to this script's directory
    base_dir = os.path.dirname(os.path.abspath(__file__))
    backup_path = os.path.join(base_dir, "flows_backup.json")
    deploy_path = os.path.join(base_dir, "flows_to_deploy.json")
    src_dir = os.path.join(base_dir, "src")
    
    if not os.path.exists(backup_path):
        # Fall back to root directory if not found in nodered/
        root_backup = "/home/alexkzk/IdeaProjects/SmartHouse/flows_backup.json"
        if os.path.exists(root_backup):
            import shutil
            shutil.copy(root_backup, backup_path)
            print(f"Copied backup from root to {backup_path}")
        else:
            print(f"Error: {backup_path} does not exist.")
            return

    with open(backup_path, "r") as f:
        flows = json.load(f)

    # Filter out existing nodes belonging to light_control_tab to allow clean re-runs
    flows = [node for node in flows if node.get("z") != "light_control_tab" and node.get("id") != "light_control_tab"]

    # Define helper to read JS files safely
    def read_js(filename):
        path = os.path.join(src_dir, filename)
        with open(path, "r", encoding="utf-8") as f:
            return f.read()

    rolling_average_js = read_js("rolling_average.js")
    power_control_js = read_js("power_control.js")
    physical_switch_js = read_js("physical_switch.js")
    daily_10pm_js = read_js("daily_10pm.js")

    new_nodes = []

    # 1. Tab Node
    new_nodes.append({
        "id": "light_control_tab",
        "type": "tab",
        "label": "Light Control Logic",
        "disabled": False,
        "info": "Automatic Lux and Manual Override Control Logic for SmartHouse Lights (LR-LUTV, MB-LOB, MB-LOTV, TER-LIGHTS)"
    })

    # 2. Database Sync on Startup
    new_nodes.append({
        "id": "db_startup_inject",
        "type": "inject",
        "z": "light_control_tab",
        "name": "Once on Startup",
        "props": [{"p": "payload"}],
        "repeat": "",
        "crontab": "",
        "once": True,
        "onceDelay": 0.1,
        "topic": "",
        "payload": "",
        "payloadType": "date",
        "x": 130,
        "y": 80,
        "wires": [["db_startup_query"]]
    })

    new_nodes.append({
        "id": "db_startup_query",
        "type": "function",
        "z": "light_control_tab",
        "name": "SQL: Select Initial States",
        "func": "msg.payload = \"SELECT json_agg(t) FROM (SELECT code, state, locked, locked_until_utc FROM main.appliance WHERE code IN ('LR-LUTV', 'MB-LOB', 'MB-LOTV', 'TER-LIGHTS')) t;\";\nreturn msg;",
        "outputs": 1,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 370,
        "y": 80,
        "wires": [["db_startup_exec"]]
    })

    new_nodes.append({
        "id": "db_startup_exec",
        "type": "exec",
        "z": "light_control_tab",
        "command": "PGPASSWORD=smarthouse psql -h 192.168.0.201 -p 24870 -U smarthouse -d smarthouse -t -A -c",
        "addpay": True,
        "append": "",
        "useSpawn": "false",
        "timer": "",
        "winHide": False,
        "oldrc": False,
        "name": "Exec: psql startup query",
        "x": 630,
        "y": 80,
        "wires": [["db_startup_sync"], [], []]
    })

    new_nodes.append({
        "id": "db_startup_sync",
        "type": "function",
        "z": "light_control_tab",
        "name": "Parse & Sync States",
        "func": "try {\n    let raw = msg.payload.trim();\n    if (!raw || raw === \"null\") {\n        node.warn(\"Startup sync: DB returned no data\");\n        return null;\n    }\n    let rows = JSON.parse(raw);\n    let states = flow.get(\"light_states\") || {};\n    for (let row of rows) {\n        let lockedUntil = null;\n        if (row.locked_until_utc) {\n            lockedUntil = new Date(row.locked_until_utc + \"Z\").getTime();\n        }\n        states[row.code] = {\n            state: row.state,\n            locked: row.locked === true || row.locked === 't',\n            lockedUntil: lockedUntil,\n            lastCommandedState: null\n        };\n    }\n    flow.set(\"light_states\", states);\n    node.log(\"Synced states from DB: \" + JSON.stringify(states));\n} catch(e) {\n    node.error(\"Failed to parse DB sync payload: \" + e.message + \". Payload: \" + msg.payload);\n}\nreturn null;",
        "outputs": 1,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 870,
        "y": 80,
        "wires": [[]]
    })

    # 3. Rolling average lux processor
    new_nodes.append({
        "id": "mqtt_in_outdoor_lux",
        "type": "mqtt in",
        "z": "light_control_tab",
        "name": "Outdoor Lux Sensor In",
        "topic": "zigbee2mqtt/mb-lis-outdoor",
        "qos": "2",
        "datatype": "json",
        "broker": "476ae883",
        "inputs": 0,
        "x": 140,
        "y": 180,
        "wires": [["lux_rolling_average"]]
    })

    new_nodes.append({
        "id": "lux_rolling_average",
        "type": "function",
        "z": "light_control_tab",
        "name": "Calculate 5-Min Rolling Average",
        "func": rolling_average_js,
        "outputs": 1,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 410,
        "y": 180,
        "wires": [["debug_lux_average"]]
    })

    new_nodes.append({
        "id": "debug_lux_average",
        "type": "debug",
        "z": "light_control_tab",
        "name": "Debug Lux Avg",
        "active": True,
        "tosidebar": True,
        "console": False,
        "tostatus": False,
        "complete": "payload",
        "targetType": "msg",
        "statusVal": "",
        "statusType": "auto",
        "x": 660,
        "y": 180,
        "wires": []
    })

    # 4. Shared Exec Node for DB Updates & Events
    new_nodes.append({
        "id": "db_exec_node",
        "type": "exec",
        "z": "light_control_tab",
        "command": "PGPASSWORD=smarthouse psql -h 192.168.0.201 -p 24870 -U smarthouse -d smarthouse -t -A -c",
        "addpay": True,
        "append": "",
        "useSpawn": "false",
        "timer": "",
        "winHide": False,
        "oldrc": False,
        "name": "Exec: psql update & event",
        "x": 890,
        "y": 300,
        "wires": [[], [], []]
    })

    # 5. Dynamic MQTT Out Node
    new_nodes.append({
        "id": "dynamic_mqtt_out",
        "type": "mqtt out",
        "z": "light_control_tab",
        "name": "Dynamic MQTT Out",
        "topic": "",
        "qos": "0",
        "retain": False,
        "respTopic": "",
        "contentType": "",
        "userProps": "",
        "correl": "",
        "expiry": "",
        "broker": "476ae883",
        "x": 890,
        "y": 420,
        "wires": []
    })

    # 6. Power Control Engine Scheduler Loop
    new_nodes.append({
        "id": "pwr_control_inject",
        "type": "inject",
        "z": "light_control_tab",
        "name": "Every 10 Seconds",
        "props": [{"p": "payload"}],
        "repeat": "10",
        "crontab": "",
        "once": False,
        "onceDelay": 0.1,
        "topic": "",
        "payload": "",
        "payloadType": "date",
        "x": 130,
        "y": 420,
        "wires": [["pwr_control_engine"]]
    })

    new_nodes.append({
        "id": "pwr_control_engine",
        "type": "function",
        "z": "light_control_tab",
        "name": "Power Control Engine",
        "func": power_control_js,
        "outputs": 2,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 380,
        "y": 420,
        "wires": [["db_exec_node"], ["dynamic_mqtt_out"]]
    })

    # 7. Physical Switch Handlers (Status Receivers)
    new_nodes.append({
        "id": "mqtt_in_status_lr_lutv",
        "type": "mqtt in",
        "z": "light_control_tab",
        "name": "LR-LUTV Status In",
        "topic": "zigbee2mqtt/LR-LUTV",
        "qos": "2",
        "datatype": "json",
        "broker": "476ae883",
        "inputs": 0,
        "x": 130,
        "y": 240,
        "wires": [["physical_switch_handler"]]
    })

    new_nodes.append({
        "id": "mqtt_in_status_mb_lob",
        "type": "mqtt in",
        "z": "light_control_tab",
        "name": "MB-LOB Status In",
        "topic": "zigbee2mqtt/MB-LOB",
        "qos": "2",
        "datatype": "json",
        "broker": "476ae883",
        "inputs": 0,
        "x": 130,
        "y": 280,
        "wires": [["physical_switch_handler"]]
    })

    new_nodes.append({
        "id": "mqtt_in_status_mb_lotv",
        "type": "mqtt in",
        "z": "light_control_tab",
        "name": "MB-LOTV Status In",
        "topic": "zigbee2mqtt/MB-LOTV",
        "qos": "2",
        "datatype": "json",
        "broker": "476ae883",
        "inputs": 0,
        "x": 130,
        "y": 320,
        "wires": [["physical_switch_handler"]]
    })

    new_nodes.append({
        "id": "mqtt_in_status_ter_lights",
        "type": "mqtt in",
        "z": "light_control_tab",
        "name": "TER-LIGHTS Status In",
        "topic": "zigbee2mqtt/TER-LIGHTS",
        "qos": "2",
        "datatype": "json",
        "broker": "476ae883",
        "inputs": 0,
        "x": 130,
        "y": 360,
        "wires": [["physical_switch_handler"]]
    })

    new_nodes.append({
        "id": "physical_switch_handler",
        "type": "function",
        "z": "light_control_tab",
        "name": "Physical Switch override",
        "func": physical_switch_js,
        "outputs": 2,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 410,
        "y": 300,
        "wires": [["db_exec_node"], ["dynamic_mqtt_out"]]
    })

    # 8. Daily 10:00 PM cron-injector
    new_nodes.append({
        "id": "daily_10pm_inject",
        "type": "inject",
        "z": "light_control_tab",
        "name": "Daily at 10 PM America/New_York",
        "props": [],
        "repeat": "",
        "crontab": "00 22 * * *",
        "once": False,
        "onceDelay": 0.1,
        "topic": "",
        "payloadType": "date",
        "x": 170,
        "y": 520,
        "wires": [["daily_10pm_processor"]]
    })

    new_nodes.append({
        "id": "daily_10pm_processor",
        "type": "function",
        "z": "light_control_tab",
        "name": "10 PM Group OFF Handler",
        "func": daily_10pm_js,
        "outputs": 2,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 420,
        "y": 520,
        "wires": [["db_exec_node"], ["dynamic_mqtt_out"]]
    })

    flows.extend(new_nodes)

    with open(deploy_path, "w") as f:
        json.dump(flows, f, indent=2)
    print(f"Successfully generated {deploy_path} with {len(flows)} total nodes (appended {len(new_nodes)} new nodes)!")

if __name__ == "__main__":
    merge()
