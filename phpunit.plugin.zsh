alias pu='phpunit_cmd';
alias puinit='phpunit_cmd --generate-configuration';

phpunit_cmd() {
    eval "$(__phpunit_cmd) $@";
}

# Generates phpunit command
__phpunit_cmd() {
    local project_dir="$(__phpunit_project_dir)";
    local phpunit_bin="$(__phpunit_bin $project_dir)";
    local phpunit_config_dir="$(__phpunit_config_dir $project_dir)";

    if [[ "$phpunit_config_dir" == '' ]]; then
        echo "$phpunit_bin";
    else
        echo "$phpunit_bin -c $phpunit_config_dir";
    fi
}

# Finds phpunit executable
__phpunit_bin() {
    local project_dir="${1:-$(__phpunit_project_dir)}";

    (
        find \
            "$project_dir" \
            "$project_dir/bin" \
            "$project_dir/tools" \
            "$project_dir/vendor/bin" \
            -name 'phpunit' -maxdepth 1 2>/dev/null;
        echo 'phpunit'
    ) | head -n1;
}

# Finds project dir
__phpunit_project_dir() {
    local project_dir="$PWD";
    local dir="$project_dir";

    while ((1)); do

        if [[ -f "$dir/composer.json" ]]; then
            project_dir="$dir";
            break;
        fi

        [[ "$dir" == '' ]] && break;

        dir="${dir%/*}";
    done

    echo "$project_dir";
}

__phpunit_config_dir() {
    local project_dir="${1:-$(__phpunit_project_dir)}";
    local phpunit_config_file=$(find "$project_dir" -maxdepth 2 -name 'phpunit.xml*' -type f 2>/dev/null | head -n 1);
    local phpunit_config_dir="${phpunit_config_file%/phpunit.xml*}";

    echo "$phpunit_config_dir";
}

_phpunit() {
    _arguments -s -w \
        '(-)'{-h,--help}'[Prints this usage information]' \
        '(-c|--configuration)'{-c,--configuration}'[Read configuration from XML file]:configuration:_files -/' \
        '(-v|--verbose)'{-v,--verbose}'[Output more verbose information]' \
        '--atleast-version=[Checks that version is greater than min and exits]:integer' \
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
        '--disable-coverage-ignore[Disable annotations for ignoring code coverage]' \
        '--disallow-resource-usage[Be strict about resource usage during small tests]' \
        '--disallow-test-output[Be strict about output during tests]' \
        '--disallow-todo-tests[Does not execute tests which have the @todo annotation in its docblock]' \
        '--dont-report-useless-tests[Do not report tests that do not test anything]' \
        '--enforce-time-limit[Enforce time limit based on test size]' \
        '--exclude-group[Exclude tests from the specified group(s)]' \
        '--fail-on-risky[Treat risky tests as failures]' \
        '--fail-on-warning[Treat tests with warnings as failures]' \
        '--filter[Filter which tests to run]' \
        '--generate-configuration[Generate configuration file with suggested settings]' \
        '--group[Only runs tests from the specified group(s)]' \
        '--globals-backup[Backup and restore $GLOBALS for each test]' \
        '--include-path[Prepend PHP include_path with given path(s)]:include path:_files -/' \
        '--list-groups[List available test groups]' \
        '--list-suites[List available test suites]' \
        '--loader[TestSuiteLoader implementation to use]' \
        '--log-junit[Log test execution in JUnit XML format to file]:log junit:_files -/' \
        '--log-teamcity[Log test execution in TeamCity format to file]:log teamcity:_files -/' \
        '--no-configuration[Ignore default configuration file (phpunit.xml)]' \
        '--no-coverage[Ignore code coverage configuration]' \
        '--no-extensions[Do not load PHPUnit extensions]' \
        '--no-globals-backup[Do not backup and restore $GLOBALS]' \
        '--printer[Specifies the result printer to use]' \
        '--process-isolation[Run each test in a separate PHP process]' \
        '--repeat[Repeatedly runs the test(s) the specified number of times]:number of times' \
        '--reverse-list[Print defects in reverse order]' \
        '--static-backup[Backup and restore static attributes of user-defined classes]' \
        '--stderr[Write to STDERR instead of STDOUT]' \
        '--stop-on-error[Stop execution upon first error]' \
        '--stop-on-failure[Stop execution upon first error or failure]' \
        '--stop-on-incomplete[Stop execution upon first incomplete test]' \
        '--stop-on-risky[Stop execution upon first risky test]' \
        '--stop-on-skipped[Stop execution upon first skipped test]' \
        '--stop-on-warning[Stop execution upon first warning]' \
        '--strict-coverage[Be strict about unintentionally covered code]' \
        '--strict-global-state[Be strict about global state manipulation]' \
        '--strict[Run tests in strict mode]' \
        '--teamcity[Report test execution progress in TeamCity format]' \
        '--test-suffix[Only search for test in files with specified suffix(es). Default: Test.php,.phpt]' \
        '--testdox-html[Write agile documentation in HTML format to file]:testdoc html:_files -/' \
        '--testdox-text[Write agile documentation in Text format to file]:testdoc text:_files -/' \
        '--testdox-xml[Write agile documentation in XML format to file]:testdoc xml:_files -/' \
        '--testdox-group[Only include tests from the specified group(s)]' \
        '--testdox-exclude-group[Exclude tests from the specified group(s)]' \
        '--testdox[Report test execution progress in TestDox format]' \
        '--testsuite[Only runs the test suite whose name matches the given pattern]' \
        '--version[Prints the version and exits]' \
        '--whitelist[Whitelist dir for code coverage analysis]:whitelist dir:_files -/' \
        '-d[Sets a php.ini value]' \
        '*:file:_files -/' && return 0
}

puwatch() {
    if ! which 'inotifywait' > /dev/null; then
        echo 'Command "inotifywait" not found. Try to install the "inotify-tools" package.' >&2;
        return 1;
    fi

    local src_dir="${1%/}";
    local test_dir="${2%/}";

    if [[ -z "$src_dir" ]]; then
        if [[ -d './src' ]]; then
            src_dir='./src';
        else
            src_dir='.';
        fi
    fi

    if [[ -z "$test_dir" ]]; then
        if [[ -d 'tests' ]]; then
            test_dir='./tests';
        elif [[ -d 'Tests'  ]]; then
            test_dir='./Tests';
        else
            test_dir='.';
        fi
    fi

    clear;
    __puwatch_header "$src_dir" "$test_dir";

    inotifywait -mre modify \
        --format '%w%f' \
        --exclude '(/\.|/vendor/|\[^.\]\[^p\]\[^h\]\[^p\]$)' \
        "$src_dir" "$test_dir" | \

    while read file; do

        [[ "$file" == "$test_dir"* && ! "$test_dir" == "$src_dir" && ! "${file: -8}" == 'Test.php' ]] && continue;

        local test_file="$file";
        if [[ ! "${file: -8}" == 'Test.php' ]]; then
            test_file="${${file/$src_dir/$test_dir}//.php/Test.php}";
        fi

        clear;
        __puwatch_header "$src_dir" "$test_dir";

        if [[ -f "$test_file" ]]; then
            echo -e "\e[33m${test_file}\e[0m";
            echo;
            phpunit_cmd --colors --columns="$(tput cols)" "$test_file";
        else
            echo -e "\e[31mFile \"\e[91m${test_file}\e[31m\" not exists!\e[0m" >&2;
            echo;
        fi

    done
}

__puwatch_header() {
    echo "[$(date '+%F %H:%M:%S')]";
    echo;
    echo -e "\e[92mSources:\e[0m ${1}\e[0m";
    echo -e "\e[92mTests:\e[0m   ${2}\e[0m";
    echo;
}

compdef _phpunit phpunit
compdef _phpunit phpunit_cmd
compdef _phpunit pu
