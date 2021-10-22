
watch kubectl get all

kubectl logs -f job.batch/um-login-service-config

kubectl logs -f statefulset.apps/um-login-service-opendj-init-ss

kubectl logs -f job.batch/um-login-service-persistence-init-ss

kubectl logs -f statefulset.apps/um-login-service-oxtrust-ss
