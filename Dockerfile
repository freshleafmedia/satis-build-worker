FROM composer/satis

COPY entrypoint.sh /usr/local/bin/

CMD ["entrypoint.sh"]
