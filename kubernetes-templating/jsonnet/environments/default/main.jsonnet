{
  adservice: {
    deployment: {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      metadata: {
        name: 'adservice',
      },
      spec: {
        selector: {
          matchLabels: {
            app: 'adservice',
          },
        },
        template: {
          metadata: {
            labels: {
              app: 'adservice',
            },
          },
          spec: {
            containers: [
              {
                image: 'gcr.io/google-samples/microservices-demo/adservice:v0.3.5',
                name: 'adservice',
                ports: [{
                    containerPort: 9555
                }],
                env: [
                {
                  name: 'PORT',
                  value: '9555',
                },
                {
                  name: 'DISABLE_PROFILER',
                  value: '1',
                }
              ],
              },
            ],
          },
        },
      },
    },
    service: {
      apiVersion: 'v1',
      kind: 'Service',
      metadata: {
        labels: {
          name: 'adservice',
        },
        name: 'adservice',
      },
      spec: {
        ports: [{
            name: 'adservice',
            port: 9555,
            targetPort: 9555,
        }],
        selector: {
          app: 'adservice',
        },
        type: 'ClusterIP',
      },
    },
  }
}