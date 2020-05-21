FROM composer/satis

COPY entrypoint.sh /

CMD ["/entrypoint.sh"]
