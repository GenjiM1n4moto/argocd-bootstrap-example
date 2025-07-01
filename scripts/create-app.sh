#!/bin/bash

# 用法: ./create-app.sh <app-name> <chart-path>
# 示例: ./create-app.sh my-app charts/my-app

APP_NAME=$1
CHART_PATH=$2

if [ -z "$APP_NAME" ] || [ -z "$CHART_PATH" ]; then
    echo "用法: $0 <app-name> <chart-path>"
    echo "示例: $0 my-app charts/my-app"
    exit 1
fi

# 创建环境配置目录
mkdir -p environments/dev
mkdir -p environments/stage
mkdir -p environments/prod

# 创建环境特定的 values 文件
cat > environments/dev/values-${APP_NAME}.yaml << EOF
replicaCount: 1
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: ${APP_NAME}-dev.local
      paths:
        - path: /
          pathType: Prefix
resources:
  requests:
    memory: "64Mi"
    cpu: "50m"
  limits:
    memory: "128Mi"
    cpu: "100m"
EOF

cat > environments/stage/values-${APP_NAME}.yaml << EOF
replicaCount: 2
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: ${APP_NAME}-stage.local
      paths:
        - path: /
          pathType: Prefix
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
EOF

cat > environments/prod/values-${APP_NAME}.yaml << EOF
replicaCount: 3
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: ${APP_NAME}.local
      paths:
        - path: /
          pathType: Prefix
resources:
  requests:
    memory: "256Mi"
    cpu: "200m"
  limits:
    memory: "512Mi"
    cpu: "500m"
EOF

# 创建 Application 文件
mkdir -p apps/dev apps/stage apps/prod

cat > apps/dev/${APP_NAME}.yaml << EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${APP_NAME}-dev
  namespace: argocd
spec:
  project: teama-dev
  source:
    repoURL: https://github.com/GenjiM1n4moto/argocd-bootstrap-example.git
    targetRevision: develop
    path: ${CHART_PATH}
    helm:
      valueFiles:
        - values.yaml
        - environments/dev/values-${APP_NAME}.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: develop
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF

cat > apps/stage/${APP_NAME}.yaml << EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${APP_NAME}-stage
  namespace: argocd
spec:
  project: teama-stage
  source:
    repoURL: https://github.com/GenjiM1n4moto/argocd-bootstrap-example.git
    targetRevision: staging
    path: ${CHART_PATH}
    helm:
      valueFiles:
        - values.yaml
        - environments/stage/values-${APP_NAME}.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: stage
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF

cat > apps/prod/${APP_NAME}.yaml << EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${APP_NAME}-prod
  namespace: argocd
spec:
  project: teama-prod
  source:
    repoURL: https://github.com/GenjiM1n4moto/argocd-bootstrap-example.git
    targetRevision: HEAD
    path: ${CHART_PATH}
    helm:
      valueFiles:
        - values.yaml
        - environments/prod/values-${APP_NAME}.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: prod
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF

echo "✅ 成功创建应用 ${APP_NAME} 的配置"
echo "📁 创建的文件:"
echo "  - environments/dev/values-${APP_NAME}.yaml"
echo "  - environments/stage/values-${APP_NAME}.yaml"
echo "  - environments/prod/values-${APP_NAME}.yaml"
echo "  - apps/dev/${APP_NAME}.yaml"
echo "  - apps/stage/${APP_NAME}.yaml"
echo "  - apps/prod/${APP_NAME}.yaml"
echo ""
echo "🔧 下一步:"
echo "  1. 检查并调整环境特定配置"
echo "  2. 提交到 Git 仓库"
echo "  3. 在 ArgoCD 中应用配置" 