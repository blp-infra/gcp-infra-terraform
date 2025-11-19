Below is the **complete step-by-step REAL-TIME MongoDB → Pub/Sub → Cloud Run → GCS pipeline** for your **single GCP VM**.

This includes:

✔️ Convert standalone MongoDB → **single-node replica set**
✔️ Install **change stream listener** on VM
✔️ Publish every change to **Pub/Sub**
✔️ Use **Cloud Run** (not Cloud Function)
✔️ Cloud Run writes JSON events to **GCS bucket**
✔️ End-to-end real-time syncing

---

#  **FULL PIPELINE OVERVIEW**

```
GCP VM → MongoDB Change Streams → Python Listener → Pub/Sub → Cloud Run → GCS Bucket
```

---

# ---------------------------------------------------------

# 🟦 **STEP 1 — Convert MongoDB Standalone → Single Node Replica Set**

# ---------------------------------------------------------

### 1. Edit MongoDB configuration

Open:

```bash
sudo nano /etc/mongod.conf
```

Add:

```yaml
replication:
  replSetName: "rs0"
```

Save → exit.

### 2. Restart MongoDB

```bash
sudo systemctl restart mongod
```

### 3. Initiate replica set

```bash
mongosh --eval "rs.initiate()"
```

### 4. Verify

```bash
mongosh --eval "rs.status()"
```

You should see: `"set" : "rs0"` and `"myState" : 1`.

MongoDB is now ready for **Change Streams**.

---

# ---------------------------------------------------------

# 🟦 **STEP 2 — Install REAL-TIME MongoDB Change Stream Listener**

# ---------------------------------------------------------

### Install dependencies

```bash
sudo apt update
sudo apt install python3 python3-pip -y
pip3 install pymongo google-cloud-pubsub
```

### Create Pub/Sub topic

```bash
gcloud pubsub topics create mongo-changes
```

### Create listener: `/opt/mongo-watcher/mongo-watcher.py`

```python
from pymongo import MongoClient
from google.cloud import pubsub_v1
import json

MONGO_URI = "mongodb://localhost:27017"
PROJECT_ID = "YOUR_PROJECT_ID"
TOPIC_ID = "mongo-changes"

client = MongoClient(MONGO_URI)
db = client["mydb"]  # Your DB

publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path(PROJECT_ID, TOPIC_ID)

print("Listening for MongoDB changes...")

while True:
    try:
        with db.watch() as stream:
            for change in stream:
                data = json.dumps(change).encode("utf-8")
                publisher.publish(topic_path, data)
                print("Published:", change)
    except Exception as e:
        print("Error, retrying:", e)
        continue
```

### Run it once to test:

```bash
python3 /opt/mongo-watcher/mongo-watcher.py
```

If you insert something:

```bash
mongosh
db.users.insertOne({name:"John"})
```

You will see it publish to Pub/Sub.

---

# ---------------------------------------------------------

# 🟦 **STEP 3 — (OPTIONAL BUT RECOMMENDED) Run Listener as Systemd Service**

# ---------------------------------------------------------

Create service:

```bash
sudo nano /etc/systemd/system/mongo-watcher.service
```

Add:

```
[Unit]
Description=MongoDB Change Stream Listener
After=network.target mongod.service

[Service]
ExecStart=/usr/bin/python3 /opt/mongo-watcher/mongo-watcher.py
Restart=always
User=root
Environment="GOOGLE_APPLICATION_CREDENTIALS=/path/to/gcp-sa.json"

[Install]
WantedBy=multi-user.target
```

Start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now mongo-watcher
```

---

# ---------------------------------------------------------

# 🟦 **STEP 4 — Create GCS Bucket**

# ---------------------------------------------------------

```bash
gsutil mb gs://mongo-realtime-sync
```

---

# ---------------------------------------------------------

# 🟦 **STEP 5 — Create Cloud Run Service to store messages in GCS**

# ---------------------------------------------------------

### Create folder for Cloud Run source

```
cloudrun-mongo-to-gcs/
├── main.py
├── requirements.txt
└── Dockerfile
```

---

### `requirements.txt`

```
google-cloud-storage
google-cloud-pubsub
flask
```

---

### `main.py`

Cloud Run will receive Pub/Sub push:

```python
import base64
import json
import time
from flask import Flask, request
from google.cloud import storage

app = Flask(__name__)
bucket = storage.Client().bucket("mongo-realtime-sync")

@app.post("/")
def index():
    envelope = request.get_json()
    data = base64.b64decode(envelope["message"]["data"]).decode("utf-8")
    change = json.loads(data)

    collection = change.get("ns", {}).get("coll", "unknown")
    ts = int(time.time())
    filename = f"{collection}/{ts}.json"

    blob = bucket.blob(filename)
    blob.upload_from_string(json.dumps(change), content_type="application/json")

    return ("", 204)
```

---

### `Dockerfile`

```Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "main.py"]
```

---

# ---------------------------------------------------------

# 🟦 **STEP 6 — Deploy Cloud Run Service**

# ---------------------------------------------------------

```bash
gcloud run deploy mongo-to-gcs \
  --source ./cloudrun-mongo-to-gcs \
  --region asia-south1 \
  --allow-unauthenticated
```

Copy the URL.

Example:

```
https://mongo-to-gcs-xxxx.a.run.app
```

---

# ---------------------------------------------------------

# 🟦 **STEP 7 — Create Pub/Sub Push Subscription → Cloud Run**

# ---------------------------------------------------------

Create subscription:

```bash
gcloud pubsub subscriptions create mongo-sub \
  --topic mongo-changes \
  --push-endpoint="https://mongo-to-gcs-xxxx.a.run.app" \
  --push-auth-service-account=cloud-run@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

Pub/Sub will now push every MongoDB change → Cloud Run.

---

# ---------------------------------------------------------

# 🟩 **FINAL FLOW (REAL-TIME)**

# ---------------------------------------------------------

```
(1) GCP VM
     ↓ MongoDB Change Stream
(2) Listener (python)
     ↓ Pub/Sub message
(3) Pub/Sub Topic
     ↓ push
(4) Cloud Run
     ↓ save
(5) GCS Bucket (mongo-realtime-sync)
```

Every insert/update/delete becomes:

```
users/1732029912.json
orders/1732029925.json
inventory/1732029931.json
```



