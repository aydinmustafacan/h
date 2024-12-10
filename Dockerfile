# Stage 1: Build the C++ application
FROM --platform=linux/amd64 ubuntu:22.04 AS build

# Install essential build dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    zip \
    python3 \
    python3-pip \
    build-essential \
    libtool \
    make \
    git \
    openjdk-11-jdk \
    bash \
    ca-certificates \
    autoconf \
    pkg-config \
    && apt-get clean

# Verify the correct GCC version is being used (11.x)
RUN gcc --version && g++ --version

# Install Bazel 5.4.0 for x86_64
RUN curl -fLo /usr/local/bin/bazel https://github.com/bazelbuild/bazel/releases/download/5.4.0/bazel-5.4.0-linux-x86_64 && \
    chmod +x /usr/local/bin/bazel

# Verify Bazel installation
RUN bazel version

# Create and set the working directory
WORKDIR /app

# Copy the project files into the container
COPY . .

# Build the client target using Bazel
# For client cd client && bazel build //:client --verbose_failures
RUN cd client && bazel build //:client --verbose_failures

# Stage 2: Create a lightweight runtime image
FROM --platform=linux/amd64 ubuntu:22.04 AS runtime

# Copy the compiled binary from the build stage
COPY --from=build /app/client/bazel-bin/client /usr/local/bin/client

# Set default command to run the binary
CMD ["/usr/local/bin/client"]
