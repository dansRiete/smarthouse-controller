import json
import urllib.request
import os

base_dir = os.path.dirname(os.path.abspath(__file__))
deploy_path = os.path.join(base_dir, "flows_to_deploy.json")
url = "http://192.168.0.201:31880/flows"

print(f"Reading flows from {deploy_path}...")
if not os.path.exists(deploy_path):
    print(f"Error: {deploy_path} does not exist. Running merge_flows.py first...")
    import merge_flows
    merge_flows.merge()

with open(deploy_path, "r") as f:
    data = json.load(f)

print(f"Sending POST request to {url} with {len(data)} nodes...")
req = urllib.request.Request(
    url,
    data=json.dumps(data).encode("utf-8"),
    headers={
        "Content-Type": "application/json",
        "Node-RED-Deployment-Type": "full"
    },
    method="POST"
)

try:
    with urllib.request.urlopen(req, timeout=15) as response:
        status = response.status
        html = response.read().decode("utf-8")
        print(f"Success! HTTP Status: {status}")
        print("Response:")
        print(html)
except Exception as e:
    print("Error deploying flows:", e)
