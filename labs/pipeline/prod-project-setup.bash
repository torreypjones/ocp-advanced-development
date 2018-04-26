oc new-project tjones-tasks-prod --display-name "Tasks Production"
oc policy add-role-to-group system:image-puller system:serviceaccounts:tjones-tasks-prod -n tjones-tasks-dev
oc policy add-role-to-user edit system:serviceaccount:tjones-jenkins:jenkins -n tjones-tasks-prod
oc policy add-role-to-user edit system:serviceaccount:tjones-jenkins:default -n tjones-tasks-prod

# Create Blue Application
oc new-app tjones-tasks-dev/tasks:0.0 --name=tasks-blue --allow-missing-imagestream-tags=true -n tjones-tasks-prod
oc set triggers dc/tasks-blue --remove-all -n tjones-tasks-prod
oc expose dc tasks-blue --port 8080 -n tjones-tasks-prod
oc create configmap tasks-blue-config --from-literal="application-users.properties=Placeholder" --from-literal="application-roles.properties=Placeholder" -n tjones-tasks-prod
oc set volume dc/tasks-blue --add --name=jboss-config --mount-path=/opt/eap/standalone/configuration/application-users.properties --sub-path=application-users.properties --configmap-name=tasks-blue-config -n tjones-tasks-prod
oc set volume dc/tasks-blue --add --name=jboss-config1 --mount-path=/opt/eap/standalone/configuration/application-roles.properties --sub-path=application-roles.properties --configmap-name=tasks-blue-config -n tjones-tasks-prod

# Create Green Application
oc new-app tjones-tasks-dev/tasks:0.0 --name=tasks-green --allow-missing-imagestream-tags=true -n tjones-tasks-prod
oc set triggers dc/tasks-green --remove-all -n tjones-tasks-prod
oc expose dc tasks-green --port 8080 -n tjones-tasks-prod
oc create configmap tasks-green-config --from-literal="application-users.properties=Placeholder" --from-literal="application-roles.properties=Placeholder" -n tjones-tasks-prod
oc set volume dc/tasks-green --add --name=jboss-config --mount-path=/opt/eap/standalone/configuration/application-users.properties --sub-path=application-users.properties --configmap-name=tasks-green-config -n tjones-tasks-prod
oc set volume dc/tasks-green --add --name=jboss-config1 --mount-path=/opt/eap/standalone/configuration/application-roles.properties --sub-path=application-roles.properties --configmap-name=tasks-green-config -n tjones-tasks-prod

# Expose Blue service as route to make blue application active
oc expose svc/tasks-blue --name tasks -n tjones-tasks-prod

