set -e;

echo "Collecting SSH host keys"
ssh-keyscan -Ht rsa bitbucket.org github.com 2> /dev/null >> /root/.ssh/known_hosts
echo "Collected $(wc -l <<< /root/.ssh/known_hosts) keys"

echo "Waiting for packages that need building..."
while true; do
  queueEntry="$(ls -t /packageQueue | head -n 1)"

  [[ "${queueEntry}" = "" ]] && { sleep $(( RANDOM % 10 + 5 )); continue; }

  packageUrl="$(< "/packageQueue/${queueEntry}")";

  rm "/packageQueue/${queueEntry}"

  echo "Building ${packageUrl}..."

  php /satis/bin/satis build --no-interaction --no-ansi -vv --repository-url="${packageUrl}" /satis.json /builds
done;
