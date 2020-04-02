# Build deployer docker image
	
In the project root directory
	
```	
$ export REGISTRY=gcr.io/privacy1-ab-public	
$ export APP_NAME=harpocrates
$ export TAG=1.0.1
	

$ docker build --tag $REGISTRY/$APP_NAME/deployer:$TAG .	
$ docker push $REGISTRY/$APP_NAME/deployer:$TAG
	
```

# Run CI
Trigger CI with parameter
```
TAG=1.0
PATCH=1
```
