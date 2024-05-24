# Use the latest official Ubuntu base image
FROM ubuntu:latest

# Set the environment variable to suppress interactive prompts during package installation
ENV DEBIAN_FRONTEND noninteractive

# Metadata about the maintainer of the image
LABEL MAINTAINER Amir Pourmand

# Update the package list and install required packages without recommended packages
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    locales \                # For setting up localization
    imagemagick \            # Image manipulation tool
    ruby-full \              # Ruby programming language and dependencies
    build-essential \        # Basic development tools (compilers, etc.)
    zlib1g-dev \             # Zlib development library
    jupyter-nbconvert \      # Jupyter notebook conversion tool
    inotify-tools \          # Tools for monitoring filesystem events
    procps && \              # System utilities
    apt-get clean && \       # Clean up package lists
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*  # Remove cached files

# Uncomment the locale setting for en_US.UTF-8 in the locale.gen file and generate it
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

# Set environment variables for locale settings and Jekyll environment
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    JEKYLL_ENV=production

# Install Jekyll and Bundler gems
RUN gem install jekyll bundler

# Create a directory for the Jekyll site
RUN mkdir /srv/jekyll

# Add the Gemfile to the Jekyll directory
ADD Gemfile /srv/jekyll

# Set the working directory
WORKDIR /srv/jekyll

# Install the bundle specified in the Gemfile
RUN bundle install --no-cache

# Uncomment this if you want to remove the gem cache to save space
# && rm -rf /var/lib/gems/3.1.0/cache

# Expose port 8080 for the Jekyll server
EXPOSE 8080

# Copy the entry point script to the temporary directory
COPY bin/entry_point.sh /tmp/entry_point.sh

# Set the default command to execute the entry point script
CMD ["/tmp/entry_point.sh"]