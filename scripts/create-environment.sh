#!/bin/bash

# 用法: ./create-environment.sh <env-name> <namespace> <project-name>
# 示例: ./create-environment.sh test test-ns teama-test

ENV_NAME=$1
NAMESPACE=$2
PROJECT_NAME=$3

if [ -z "$ENV_NAME" ] || [ -z "$NAMESPACE" ] || [ -z "$PROJECT_NAME" ]; then
    echo "用法: $0 <env-name> <namespace> <project-name>"
    echo "示例: $0 test test-ns teama-test"
    exit 1
fi

# 创建环境目录
mkdir -p environments/${ENV_NAME}
mkdir -p apps/${ENV_NAME}
mkdir -p projects/${ENV_NAME}

# 创建环境特定的 values 文件
cat > environments/${ENV_NAME}/values.yaml << EOF
replicaCount: 1
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: hello-${ENV_NAME}.local
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

# 创建项目配置
cat > projects/${ENV_NAME}/${PROJECT_NAME}.yaml << EOF
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: ${PROJECT_NAME}
  namespace: argocd
spec:
  description: Team A ${ENV_NAME} Environment
  sourceRepos:
    - '*'
  destinations:
    - namespace: ${NAMESPACE}
      server: https://kubernetes.default.svc
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
EOF

# 创建 Application 文件
cat > apps/${ENV_NAME}/hello-nginx.yaml << EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: hello-nginx-${ENV_NAME}
  namespace: argocd
spec:
  project: ${PROJECT_NAME}
  source:
    repoURL: https://github.com/GenjiM1n4moto/argocd-bootstrap-example.git
    targetRevision: develop
    path: charts/hello-nginx
    helm:
      valueFiles:
        - values.yaml
        - environments/${ENV_NAME}/values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: ${NAMESPACE}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF

echo "✅ 成功创建环境 ${ENV_NAME} 的配置"
echo "📁 创建的文件:"
echo "  - environments/${ENV_NAME}/values.yaml"
echo "  - projects/${ENV_NAME}/${PROJECT_NAME}.yaml"
echo "  - apps/${ENV_NAME}/hello-nginx.yaml"
echo ""
echo "🔧 下一步:"
echo "  1. 调整环境特定配置"
echo "  2. 更新 ApplicationSet (如果使用)"
echo "  3. 提交到 Git 仓库"
echo "  4. 在 ArgoCD 中应用配置" 