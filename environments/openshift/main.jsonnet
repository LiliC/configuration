local list = import 'telemeter/lib/list.libsonnet';

// This entire file takes what we have for Kubernetes and
// generates an OpenShift specific Template on top of that.

local app =
  (import 'kube-thanos.libsonnet') +
  (import 'conprof.libsonnet') +
  (import 'telemeter.libsonnet') +
  {
    local thanos = super.thanos,

    template:
      list.asList('observatorium', {}, []) + {
        objects:
          $.thanos.template.objects +
          $.conprof.template.objects +
          $.telemeterServer.list.objects,

        parameters:
          $.thanos.template.parameters +
          $.telemeterServer.list.parameters + [
            { name: 'TELEMETER_FORWARD_URL', value: '' },
          ],
      },
  } + {
    template+: {
      parameters:
        std.filter(function(param) !(param.name == 'NAMESPACE' && param.value == 'observatorium'), super.parameters),
    },
  };

// Output only the template
app.template
