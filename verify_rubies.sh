for version in $(rvm list strings); do
    echo "======================================"
    echo "Testing with Ruby version: $version"
    echo "======================================"
    
    # Use the specified Ruby version
    rvm use $version --default

    # Create a temporary Ruby app file
    app_file="inline_ruby_app_$version.rb"
    echo "$ruby_app_content" > "$app_file"

    # Install dependencies from Gemfile if needed
    if [ -f Gemfile ]; then
        echo "Installing gems..."
        bundler_version=$(grep -oP "BUNDLED WITH\n\s+\K[0-9]+\.[0-9]+\.[0-9]+" Gemfile.lock)
        gem install bundler -v "$bundler_version"
        bundle install
    fi

    # Run the Ruby application
    echo "Running Ruby application..."
    ruby "$app_file" &
    APP_PID=$!

    # Wait a few seconds to ensure the app starts
    sleep 5

    # Check if the application is running
    if ps -p $APP_PID > /dev/null; then
        echo "Application ran successfully with Ruby $version"
        kill $APP_PID
    else
        echo "Application failed to run with Ruby $version"
        exit 1
    fi

    # Clean up the temporary Ruby app file
    rm "$app_file"
done

echo "All Ruby versions verified successfully with inline apps!"