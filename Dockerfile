# Use the official Ruby image as the base image
FROM ruby:3.2-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the Gemfile and Gemfile.lock (if exists) to the container
COPY Gemfile Gemfile.lock* ./

# Copy the gemspec
COPY pervoobr_mmcs.gemspec ./

# Copy the lib directory (needed for gemspec)
COPY lib/ ./lib/

# Install git (needed for gemspec to list files)
RUN apt-get update && apt-get install -y git

# Install dependencies
RUN bundle install

# Copy the rest of the application code
COPY . .

# Expose any necessary ports (if the bot listens on a port, but Telegram bots typically don't)
# EXPOSE 3000  # Uncomment if needed

# Command to run the bot
CMD ["ruby", "bot.rb"]