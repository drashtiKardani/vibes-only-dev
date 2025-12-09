# Vibes Only 
Information for Vibes Only project deployment. 

  
## Main server
Main instance which application & panel connected to it. Available data on this instance only manipulated by customer. 

* domain: [vo-dev.6thsolution.tech](https://vo-dev.6thsolution.tech/)
* instance subname: `dev`
* restart command: `vo-dev-restart`
* project folder name: `vibes-only/`
* sentry project: [link](https://main-sentry.6thsolution.tech/organizations/6th-solution/projects/vibes-only-dev/?project=5)
* flower celery monitoring: [link](https://vo-flower-dev.6thsolution.tech/)
* AWS S3 bucket name: video-vibes
* Git branch: `master`

## Feature server
Feature server for testing new features on docker swarm. Data on this instance is fake or can be obtained from main server backups. 
* domain: [vo-feat.6thsolution.tech](https://vo-feat.6thsolution.tech/)
* instance subname: `feat`
* restart command: `vo-feat-restart`
* project folder name: `vibes-only-backend-feature/`
* sentry project: [link](https://main-sentry.6thsolution.tech/organizations/6th-solution/projects/vibes-only-feat/?project=6)
* flower celery monitoring: [link](https://vo-flower-feat.6thsolution.tech/)
* AWS S3 bucket name: video-vibes-test
* Git branch: `backend-feature`



* flutter pub run intl_utils:generate
* dart run build_runner build -d
* For Melos:
    melos bootstrap
* For panel:
    melos run admin_panel:init