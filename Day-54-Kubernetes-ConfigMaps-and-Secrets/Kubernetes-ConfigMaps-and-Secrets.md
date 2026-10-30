# Kubernetes ConfigMaps and Secrets 

In Kubernetes, ConfigMap and Secret are used to store configuration data separately from your application container image. The main difference is that a ConfigMap stores non-sensitive configuration, while a Secret is intended for sensitive information such as passwords and tokens.

1. What is a ConfigMap?

A ConfigMap stores non-sensitive configuration data as key-value pairs.


For example, suppose your Nginx or web application needs to know which environment it's running in and what application URL to use.

Instead of hardcoding those values into your application image, you can store them in a ConfigMap.

Exmaple: 
```YAML 
apiVersion: v1 
kind: ConfigMap 
metadata: 
  name: app-config
data: 
  APP_ENV: "development"
  LOG_LEVEL: "info"
  APP_COLOR: "blue"
```
Here:
- `APP_ENV ` stores the environment name.
- `LOG_LEVEL ` defines the logging level.
- `APP_COLOR` stores a non-sensitive application setting.

**Why use it?**

-  You can change configuration without rebuilding your application image. Depending on how the application consumes the configuration, you may still need to restart or reload it for changes to take effect.

2. What is a Secret?

A Secret stores sensitive information, such as:

- Database passwords
- API tokens
- Credentials
- TLS certificates and keys

Example:

```YAML 
apiVersion: v1 
kind: Secret 
metadata: 
  name: app-secret
type: Opaque
stringData:
  DB_USERNAME: "appuser"
  DB_PASSWORD: "example-password"
```

**Important security detail:** Kubernetes Secrets are not automatically encrypted just because they're called Secrets. Their values are commonly Base64-encoded in the data field, which is not encryption. For production, use encryption at rest, restrictive RBAC permissions, and avoid committing real credentials to Git.
