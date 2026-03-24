const express = require('express');
const app = express();
const path = require('path');
const k8s = require('@kubernetes/client-node');

const PORT = process.env.PORT || 3000;

// Initialize Kubernetes client
const kc = new k8s.KubeConfig();
try {
    kc.loadFromDefault();
} catch (e) {
    console.error('Failed to load Kubernetes config:', e.message);
}

const k8sApi = kc.makeApiClient(k8s.CoreV1Api);
const appsApi = kc.makeApiClient(k8s.AppsV1Api);

app.use(express.static('.'));

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

app.get('/health', (req, res) => {
    res.status(200).json({ status: 'ok' });
});

// New API endpoint for Cluster Status
app.get('/api/cluster-status', async (req, res) => {
    try {
        const namespace = 'color-sync';
        
        // Fetch Pods
        const podRes = await k8sApi.listNamespacedPod(namespace);
        const pods = podRes.body.items.map(p => ({
            name: p.metadata.name,
            status: p.status.phase,
            restarts: p.status.containerStatuses ? p.status.containerStatuses[0].restartCount : 0,
            creationTimestamp: p.metadata.creationTimestamp
        }));

        // Fetch Deployment for Replica Counts
        const deployRes = await appsApi.readNamespacedDeployment('color-sync', namespace);
        const deploy = deployRes.body;

        res.json({
            pods: pods,
            replicas: {
                desired: deploy.spec.replicas,
                current: deploy.status.replicas,
                ready: deploy.status.readyReplicas || 0,
                updated: deploy.status.updatedReplicas || 0
            },
            timestamp: new Date().toISOString()
        });
    } catch (err) {
        // Fallback or detailed error
        res.status(500).json({ 
            error: 'Failed to fetch cluster status',
            details: err.message,
            timestamp: new Date().toISOString()
        });
    }
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server is running on port ${PORT}`);
});