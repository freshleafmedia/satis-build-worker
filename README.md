# Satis Package Build Worker

A Satis instance that will build packages from a queue.

## How It Works

- The queue is simply a directory
- Every file in the queue is a job
- The file contains the repository URL of the package to be built

## Example

The following example will read all job files inside the host directory `/host/queue` and build them, outputting the
packages to `/host/builtPackages`. It will read any config from the `/host/satis.json` file.

```
docker run -it --rm \
  --user $(id -u):$(id -g) \
  --volume /host/queue:/packageQueue \
  --volume /host/builtPackages:/build \
  --volume /host/satis.json:/satis.json \
  freshleafmedia/satis-build-worker
```

If you also want to take advantage of Composers caching (you do) then you can also add `--volume /host/composer:/composer`

### Adding to the queue

- Each job in the queue file must contain only the URL to the repo to build, eg `git@github.com:vendor/package.git` or `git@bitbucket.org:vendor/package.git`.
- The filename can be set to anything you like, it isn't read.
- The jobs are processed in the order they are added


## Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: Satis
spec:
  selector:
    matchLabels:
      app: Satis
  replicas: 2
  template:
    metadata:
      labels:
        app: Satis
    spec:
      containers:
      - name: satis
        image: "freshleafmedia/satis-build-worker:latest"
        imagePullPolicy: "Always"
        volumeMounts:
        - name: volume
          mountPath: /builds
          subPath: web/public
        - name: volume
          mountPath: /packageQueue
          subPath: packageQueue
        - name: volume
          mountPath: /composer
          subPath: composer
        - name: satis-config
          mountPath: /satis.json
          subPath: satis.json
        - name: ssh
          mountPath: /root/.ssh/id_rsa
          subPath: id_rsa
          readOnly: true
        - name: ssh
          mountPath: /root/.ssh/id_rsa.pub
          subPath: id_rsa.pub
          readOnly: true
      volumes:
      - name: volume
        persistentVolumeClaim:
          claimName: pvc
      - name: satis-config
        configMap:
          name: satis
          optional: false
      - name: ssh
        secret:
          secretName: ssh
          optional: false
          defaultMode: 0600
```

## Private Packages

This is primarily designed to work with private packages as such SSH auth is supported simply by mounting an SSH key to
the usual directory: `--volume: /host/.ssh/id_rsa.pub:id_rsa.pub:ro --volume: /host/.ssh/id_rsa:id_rsa:ro`
