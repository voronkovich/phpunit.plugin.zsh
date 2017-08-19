alias pu='phpunit_bin';

phpunit_bin() {
    local working_dir="$PWD";
    local project_dir="$working_dir";

    local dir="$working_dir";
    while ((1)); do

        if [[ -f "$dir/composer.json" ]]; then
            project_dir="$dir";
            break;
        fi

        [[ "$dir" == '' ]] && break;

        dir="${dir%/*}";
    done

    local phpunit_cmd="phpunit"

    if [[ -f "$project_dir/composer.json" ]]; then
        local vendor_dir="$project_dir/vendor";

        if [[ -f "$vendor_dir/phpunit/phpunit/phpunit" ]]; then
            phpunit_cmd="$vendor_dir/phpunit/phpunit/phpunit";
        fi
    fi

    local phpunit_config_file=$(find "$working_dir" "$project_dir" -maxdepth 2 -name 'phpunit.xml*' -type f 2>/dev/null | head -n 1);
    local phpunit_config_dir=${phpunit_config_file%/phpunit.xml*};

    if [[ ! $phpunit_config_dir == '' ]]; then
        phpunit_cmd="$phpunit_cmd -c $phpunit_config_dir";
    fi

    eval "$phpunit_cmd $@";
}

_phpunit() {
    _arguments -s -w \
        '(-)'{-h,--help}'[Prints this usage information]' \
        '(-c|--configuration)'{-c,--configuration}'[Read configuration from XML file]:configuration:_files -/' \
        '(-v|--verbose)'{-v,--verbose}'[Output more verbose information]' \
        '--bootstrap[A "bootstrap" PHP file that is run before the tests]:bootstrap:_files -/' \
        '--colors=[Use colors in output ("never", "auto" or "always")]:"always", "auto" or "never":("never" "auto" "always")' \
        '--columns[Number of columns to use for progress output]:integer or "max":("max")' \
        '--coverage-clover[Generate code coverage report in Clover XML format]:coverage clover:_files -/' \
        '--coverage-crap4j[Generate code coverage report in Crap4J XML format]:coverage crap4j:_files -/' \
        '--coverage-html[Generate code coverage report in HTML format]:coverage html:_files -/' \
        '--coverage-php[Serialize PHP_CodeCoverage object to file]:coverage php:_files -/' \
        '--coverage-text=[Generate code coverage report in text format. Default to writing to the standard output]:coverage text:_files -/' \
        '--coverage-xml[Generate code coverage report in PHPUnit XML format]:coverage xml:_files -/' \
        '--debug[Display debugging information during test execution]' \
        '--disallow-test-output[Be strict about output during tests]' \
        '--disallow-todo-tests[Does not execute tests which have the @todo annotation in its docblock]' \
        '--enforce-time-limit[Enforce time limit based on test size]' \
        '--exclude-group[Exclude tests from the specified group(s)]' \
        '--filter[Filter which tests to run]' \
        '--group[Only runs tests from the specified group(s)]' \
        '--include-path[Prepend PHP include_path with given path(s)]:include path:_files -/' \
        '--list-groups[List available test groups]' \
        '--loader[TestSuiteLoader implementation to use]' \
        '--log-json[Log test execution in JSON format]:log json:_files -/' \
        '--log-junit[Log test execution in JUnit XML format to file]:log junit:_files -/' \
        '--log-tap[Log test execution in TAP format to file]:log tap:_files -/' \
        '--no-configuration[Ignore phpunit.xml and phpunit.xml.dist from the current working directory]' \
        '--no-globals-backup[Do not backup and restore $GLOBALS]' \
        '--printer[Specifies the result printer to use]' \
        '--process-isolation[Run each test in a separate PHP process]' \
        '--repeat[Repeatedly runs the test(s) the specified number of times]:number of times' \
        '--report-useless-tests[Be strict about tests that do not test anything]' \
        '--static-backup[Backup and restore static attributes of user-defined classes]' \
        '--stderr[Optionally print to STDERR instead of STDOUT]' \
        '--stop-on-error[Stop execution upon first error]' \
        '--stop-on-failure[Stop execution upon first error or failure]' \
        '--stop-on-incomplete[Stop execution upon first incomplete test]' \
        '--stop-on-risky[Stop execution upon first risky test]' \
        '--stop-on-skipped[Stop execution upon first skipped test]' \
        '--strict-coverage[Be strict about unintentionally covered code]' \
        '--strict-global-state[Be strict about global state manipulation]' \
        '--strict[Run tests in strict mode]' \
        '--tap[Reports the test progress using the Test Anything Protocol (TAP)]' \
        '--test-suffix[Only search for test in files with specified suffix(es). Default: Test.php,.phpt]' \
        '--testdox-html[Write agile documentation in HTML format to file]:testdoc html:_files -/' \
        '--testdox-text[Write agile documentation in Text format to file]:testdoc text:_files -/' \
        '--testdox[Reports the test progress as agile documentation]' \
        '--testsuite[Only runs the test suite whose name matches the given pattern]' \
        '--version[Prints the version and exits]' \
        '-d[Sets a php.ini value]' \
        '*:file:_files -/' && return 0
}

puwatch() {
    if ! which 'inotifywait' > /dev/null; then
        echo 'Command "inotifywait" not found. Try to install the "inotify-tools" package.' >&2;
        return 1;
    fi

    local src_dir="${${1:-src}%/}";
    local test_dir="${${2:-tests}%/}";

    clear;

    echo "[$(date '+%F %H:%M:%S')]";
    echo;
    echo -e "\e[92mSources:\e[0m $src_dir\e[0m";
    echo -e "\e[92mTests:\e[0m   $test_dir\e[0m";
    echo;

    while read file; do

        [[ ! "${file: -4}" == '.php' ]] && continue;

        [[ "$file" =~ "^$test_dir/" && ! "${file: -8}" == 'Test.php' ]] && echo "$file" && continue;

        local test_file="$file";
        if [[ ! "$file" =~ 'Test.php$' ]]; then
            test_file="${${file/$src_dir/$test_dir}//.php/Test.php}";
        fi

        clear;

        echo "[$(date '+%F %H:%M:%S')]";
        echo;
        echo -e "\e[92mSources:\e[0m $src_dir\e[0m";
        echo -e "\e[92mTests:\e[0m   $test_dir\e[0m";
        echo;

        if [[ -f "$test_file" ]]; then
            echo -e "\e[33m${test_file}\e[0m";
            echo;
            pu "$test_file";
        else
            echo -e "\e[31mFile \"\e[91m${test_file}\e[31m\" not exists!\e[0m" >&2;
            echo;
        fi

    done < <(inotifywait -mre modify --format '%w%f' --exclude '.git' "$src_dir" "$test_dir");
}

compdef _phpunit phpunit
compdef _phpunit phpunit_bin
compdef _phpunit pu
