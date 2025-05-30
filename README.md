Esto es una pruebapara DeVops que demuestra un entorno de Integración Continua y Despliegue Continuo (CI/CD) completamente automatizado para una aplicación de Node.js, utilizando Docker, Kubernetes (con Kind para clústeres locales) y GitHub Actions. El objetivo es construir una solución robusta, mantenible y escalable, con foco en buenas prácticas y optimización bajo recursos limitados.

## Estructura del Proyecto


.
├── .github/
│   └── workflows/
│       └── deploy.yml      # Workflow de GitHub Actions para CI/CD
├── app/
│   ├── app.js              # Aplicación demo Node.js (Express)
│   └── package.json        # Dependencias de la aplicación Node.js
├── k8s/
│   ├── deployment.yaml     # Manifiesto de Deployment de Kubernetes
│   ├── namespace.yaml      # Manifiesto de Namespace de Kubernetes
│   ├── service.yaml        # Manifiesto de Service de Kubernetes
│   └── secret.yaml         # Manifiesto de Kubernetes Secret (mock)
├── Dockerfile              # Dockerfile optimizado para la aplicación Node.js
└── README.md               # Este archivo de documentación

## Requisitos Previos

Para ejecutar y probar este entorno localmente, necesitarás:

* *Docker Desktop:* Para construir y gestionar imágenes Docker.
* *Kind:* Kubernetes in Docker, para crear clústeres Kubernetes locales.
    * [Guía de instalación de Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
* *kubectl:* La herramienta de línea de comandos para interactuar con clústeres Kubernetes.
    * [Guía de instalación de kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* *Node.js y npm:* Para ejecutar y probar la aplicación Node.js localmente si es necesario.

## Instalación y Configuración Local

Sigue estos pasos para configurar y levantar el entorno localmente:

1.  *Clonar el Repositorio:*
    bash
    git clone [https://github.com/TU_USUARIO/TU_REPOSITORIO.git](https://github.com/TU_USUARIO/TU_REPOSITORIO.git)
    cd TU_REPOSITORIO
    

2.  *Crear el Clúster Kind:*
    bash
    kind create cluster
    
    Esto creará un clúster Kubernetes local llamado kind. Puedes verificar su estado con kubectl cluster-info.

3.  *Construir la Imagen Docker:*
    Navega al directorio raíz del proyecto y construye la imagen Docker.
    bash
    docker build -t devops-challenge-app:latest .
    

4.  *Cargar la Imagen Docker en el Clúster Kind:*
    Para que Kind pueda usar la imagen localmente construida, debes cargarla en el clúster.
    bash
    kind load docker-image devops-challenge-app:latest --name kind
    

5.  *Desplegar los Manifiestos de Kubernetes:*
    Aplica los manifiestos de Secret, Deployment, namespace y Service al clúster Kind.
    bash
    kubectl apply -f k8s/secret.yaml
    kubectl apply -f k8s/deployment.yaml
    kubectl apply -f k8s/namespace.yaml
    kubectl apply -f k8s/service.yaml

    

## Validación Post-Despliegue Local

Una vez desplegada la aplicación, puedes validar su estado:

1.  *Verificar el estado del Deployment:*
    Asegúrate de que los pods estén corriendo y listos.
    bash
    kubectl get pods -n devops-challenge
    kubectl rollout status deployment/devops-challenge-app -n devops-challenge
    

2.  *Validar el Health Check del Servicio (dentro del clúster):*
    Dado que el servicio es de tipo ClusterIP, puedes validarlo ejecutando un pod temporal y haciendo curl al servicio internamente.
    bash
    kubectl run -n devops-challenge temp-curl-pod --image=busybox --rm -it --restart=Never --command -- \
      sh -c 'wget -q -O - [http://devops-challenge-app-service.devops-challenge/health](http://devops-challenge-app-service.devops-challenge/health) | grep "status\":\"ok"'
    
    Si la salida contiene status":"ok", el servicio está funcionando correctamente.

## Ejecución de la Pipeline en GitHub

Para ejecutar la pipeline de CI/CD en GitHub Actions:

1.  *Crea un Repositorio GitHub:* Sube este proyecto a un repositorio GitHub público o privado.
2.  **Configura la rama main:** Asegúrate de que tu rama principal se llame main.
3.  **Realiza un push o abre un Pull Request:** Cualquier push a la rama main o un Pull Request dirigido a main disparará automáticamente el workflow definido en .github/workflows/deploy.yml.

Puedes ver el progreso del workflow en la pestaña "Actions" de tu repositorio de GitHub. Los logs te mostrarán cada paso, desde la construcción de la imagen hasta el despliegue y la validación en el clúster Kind efímero que se levanta para cada ejecución.

## Buenas Prácticas y Optimizaciones Implementadas

* *Docker Multi-stage Builds:* Reduce el tamaño final de la imagen Docker eliminando dependencias de construcción.
* *Imágenes base Alpine:* Utiliza node:20-alpine por su tamaño reducido, lo que acelera los tiempos de descarga y construcción.
* **npm ci --only=production:** Asegura instalaciones de dependencias limpias y enfocadas solo en producción, optimizando el tamaño y la seguridad.
* **Kubernetes readiness y liveness probes:** Mejoran la robustez y disponibilidad de la aplicación al asegurar que los pods solo reciban tráfico cuando estén listos y sean reiniciados si dejan de funcionar.
* **Kubernetes resources (requests y limits):** Permite una gestión más eficiente de los recursos del clúster y evita el consumo excesivo de recursos por parte de un solo Pod.
* **Kubernetes Secrets:** Aunque mock en este ejemplo, demuestra la forma correcta de manejar información sensible en Kubernetes.
* *GitHub Actions para CI/CD:* Automatiza el ciclo de vida de la aplicación, desde la integración hasta el despliegue, promoviendo la consistencia y reduciendo errores manuales.
* **helm/kind-action:** Facilita el aprovisionamiento de un clúster Kubernetes local efímero para pruebas en la pipeline de CI/CD.
* *Validación post-despliegue:* Incluye un paso de validación (kubectl rollout status y curl interno) para asegurar que el despliegue fue exitoso y la aplicación está operativa.
* *Separación de Manifiestos:* Los manifiestos de Kubernetes están separados por tipo (deployment.yaml, service.yaml, secret.yaml) para mejorar la organización y mantenibilidad.
* *Namespace Dedicado:* El uso de un Namespace (devops-challenge) ayuda a organizar y aislar los recursos de la aplicación dentro del clúster.

## Consideraciones Adicionales y Posibles Mejoras (Bonus)

* *Observabilidad:*
    * Integración de Prometheus para métricas y Grafana para dashboards.
    * Configuración de un stack de logging (e.g., Fluentd, Elasticsearch, Kibana/Loki, Grafana).
    * Implementación de trazabilidad distribuida (e.g., Jaeger, OpenTelemetry).
* *Tests Automáticos:*
    * Añadir pasos de pruebas unitarias, de integración y/o E2E en el workflow de CI/CD. Por ejemplo, un script npm test en la fase de build-and-deploy.
* *Gestión de Secrets más robusta:*
    * Integrar con un sistema de gestión de secretos real como HashiCorp Vault, Azure Key Vault, AWS Secrets Manager, o Google Secret Manager.
    * Utilizar herramientas como External Secrets Operator para sincronizar secretos con proveedores externos.
* *Despliegue a Múltiples Entornos:* Extender el workflow para desplegar a entornos de staging y producción.
* *Herramientas de Empaquetado:* Utilizar Helm para empaquetar y gestionar los despliegues de Kubernetes, especialmente para aplicaciones más complejas.
* *Análisis de Seguridad:* Integrar herramientas de escaneo de vulnerabilidades en imágenes Docker (e.g., Trivy, Clair) y análisis de código estático.
* *Push a un Registro de Contenedores:* Aunque no es un requisito estricto para Kind (que carga la imagen localmente), en un entorno de producción, la imagen Docker debería ser pushed a un registro como GitHub Container Registry (GHCR) o Docker Hub.
    yaml
    # Ejemplo de paso para push a GHCR en GitHub Actions
    - name: Login to GitHub Container Registry
      uses: docker/login-action@v3
      with:
        registry: ghcr.io
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    - name: Push Docker image to GHCR
      run: |
        docker tag devops-challenge-app:latest ghcr.io/${{ github.repository_owner }}/devops-challenge-app:latest
        docker push ghcr.io/${{ github.repository_owner }}/devops-challenge-app:latest
    
    Luego, el deployment.yaml debería referenciar la imagen del registro (ej: ghcr.io/TU_USUARIO/devops-challenge-app:latest).


