function gcgip --description 'Show global IP address to access a GCE instance searched by its name'
  set me (basename -s .fish (status filename))
  if not count $argv > /dev/null
    echo "Usage: $me [instance name]" >&2
    return 1
  end
  set result (gcloud compute instances list --filter "name:$argv[1]" --format json | tr -d '\n')
  if test $result = '[]'
    echo 'not found' >&2
    return 1
  end
  echo $result | jq -r '.[0].networkInterfaces[0].accessConfigs[0].natIP'
end
