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

compdef _phpunit phpunit_cmd
