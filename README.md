# ChartsHelm_delivery-app

---

## Wiki - Despliegue con ArgoCD

### 1. Estructura de entornos

```
delivery-app/
│── charts/
│   └── delivery-app/
│       ├── Chart.yaml
│       ├── values-dev.yaml
│       └── values-prod.yaml
│
│── environments/
│   ├── dev/
│   │   └── application.yaml
│   └── prod/
│       └── application.yaml
```

---

### 2. Chart principal (`Chart.yaml`)

```yaml
apiVersion: v2
name: delivery-app
description: Chart para la aplicación de gestión de pedidos (app + bd)
type: application
version: 0.1.1
appVersion: "2.5.0"
```

---

### 3. Valores por entorno

**Desarrollo** (`values-dev.yaml`)

```yaml
app:
  image:
    tag: "dev"
  replicas: 1
  resources:
    requests:
      cpu: "50m"
      memory: "256Mi"
```

**Producción** (`values-prod.yaml`)

```yaml
app:
  image:
    tag: "2.5.0"
  replicas: 3
  resources:
    requests:
      cpu: "200m"
      memory: "500Mi"
    limits:
      cpu: "500m"
      memory: "1Gi"
```

---

### 4. Aplicaciones de ArgoCD

**Dev - `environments/dev/application.yaml`**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: delivery-app-dev
spec:
  project: default
  destination:
    namespace: delivery-app-dev
    server: https://kubernetes.default.svc
  source:
    repoURL: https://andresosa21.github.io/chartsHelm-delivery-app/
    targetRevision: 0.1.1
    chart: delivery-app
    helm:
      valueFiles:
        - values-dev.yaml
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

**Prod - `environments/prod/application.yaml`**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: delivery-app-prod
spec:
  project: default
  destination:
    namespace: delivery-app-prod
    server: https://kubernetes.default.svc
  source:
    repoURL: https://andresosa21.github.io/chartsHelm-delivery-app/
    targetRevision: 0.1.1
    chart: delivery-app
    helm:
      valueFiles:
        - values-prod.yaml
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

### 5. Flujo de trabajo con ArgoCD

1. **Publicar chart** en GitHub Pages (`index.yaml` actualizado).

   ```bash
   helm package charts/delivery-app
   helm repo index --url https://andresosa21.github.io/chartsHelm-delivery-app/ .
   git add .
   git commit -m "release 0.1.1"
   git push origin main
   ```

2. **Crear Application** en ArgoCD (para dev/prod):

   ```bash
   kubectl apply -f environments/dev/application.yaml
   kubectl apply -f environments/prod/application.yaml
   ```

3. **ArgoCD sincroniza automáticamente** y aplica el chart en el namespace correspondiente.

---

Ventajas de esta organización:

* Separación clara de **entornos** (`dev`, `prod`).
* Uso de **values por entorno** sin duplicar charts.
* ArgoCD gestiona los despliegues declarativos.

---
