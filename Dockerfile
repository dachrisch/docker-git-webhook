# Use AlpineLinux as base image
FROM alpine:3.15

# Install Git
RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh

# Install Supervisor
RUN apk add --no-cache \
    supervisor

# Install Python and needed modules
RUN apk add --update \
    python3 \
    python3-dev \
    py3-pip \
    build-base \
  && pip install requests

# https://stackoverflow.com/questions/18683810/docker-supervisord-and-logging-how-to-consolidate-logs-in-docker-logs
RUN git clone https://github.com/coderanger/supervisor-stdout /opt/supervisor-stdout
RUN pip install /opt/supervisor-stdout

# Install jekyll
RUN apk add --no-cache ruby-bundler ruby-dev

RUN gem update --system

RUN gem install bundler


# Copy supervisor config
ADD conf/supervisord.conf /etc/supervisord.conf

# Copy our Scripts
ADD scripts/pull /usr/bin/pull
ADD scripts/push /usr/bin/push
ADD scripts/docker-hook /usr/bin/docker-hook
ADD scripts/hook-listener /usr/bin/hook-listener
ADD scripts/start.sh /usr/bin/start.sh
ADD scripts/run_custom_scripts_after_pull.sh /usr/bin/run_custom_scripts_after_pull.sh
ADD scripts/run_custom_scripts_after_push.sh /usr/bin/run_custom_scripts_after_push.sh
ADD scripts/run_custom_scripts_before_pull.sh /usr/bin/run_custom_scripts_before_pull.sh
ADD scripts/run_custom_scripts_before_push.sh /usr/bin/run_custom_scripts_before_push.sh
ADD scripts/run_custom_scripts_on_startup.sh /usr/bin/run_custom_scripts_on_startup.sh

# Add permissions to our scripts
RUN chmod +x /usr/bin/run_custom_scripts_after_pull.sh
RUN chmod +x /usr/bin/run_custom_scripts_after_push.sh
RUN chmod +x /usr/bin/run_custom_scripts_before_pull.sh
RUN chmod +x /usr/bin/run_custom_scripts_before_push.sh
RUN chmod +x /usr/bin/run_custom_scripts_on_startup.sh
RUN chmod 755 /usr/bin/pull && chmod 755 /usr/bin/push
RUN chmod +x /usr/bin/docker-hook
RUN chmod +x /usr/bin/hook-listener

# Add any user custom scripts + set permissions
ADD custom_scripts /custom_scripts
RUN chmod +x -R /custom_scripts

# Expose Webhook port
EXPOSE 8555

# run start script
CMD ["/bin/bash", "/usr/bin/start.sh"]
