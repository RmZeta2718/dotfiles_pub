#!/bin/bash
# conda uses hard links to reuse packages, which saves disk space
# This script shows how much disk space is saved and how many packages are reused
# Optionally shows detailed info for all packages

if [ -z "$1" ]; then
    conda_path=~/.conda
else
    conda_path=$1
fi

pkgs_dir="$conda_path"/pkgs
envs_dir="$conda_path"/envs

echo "total conda disk usage:"
du -sh "$conda_path"

echo "disk space saved by hard links:"
# find all files with more than 2 hard links, print disk space saved by hard links
# saved count = total - pkg(1) - one env(1)
find "$pkgs_dir" -type f -links +2 -printf "(%n-2)*%s\n" |
    # concat all expressoins and format to human readable
    paste -sd+ | bc | numfmt --to=iec --suffix=B
echo ""

echo "package reused count:"
reuse_table=$(
    for pkg in "$pkgs_dir"/*; do
        # https://unix.stackexchange.com/q/280805
        # get the number of hard links of each file, subtract 1 (for pkgs/ itself) and then print the max # of hard links
        # for folders with no files, output is empty string, and no influence on the final combined result
        find "$pkg" -type f -printf "%n-1\n" | bc | sort -nu | tail -n 1
        # why check all files: hard links count should be consistent in $pkg, but some times it's not
    done |
        # combine hard links count for all pkgs
        sort -n | uniq -c
)

echo "#pkg    #reuse"
echo "$reuse_table"
echo ""

# prompt user for yes/no
read -r -p "Detailed info for all pkgs? [Y/n] "
if [[ $REPLY =~ ^[Nn]$ ]]; then
    exit
fi

(
    echo "#reuse,disk usage,envs,pkg"
    for pkg in "$pkgs_dir"/*; do
        count=$(find "$pkg" -type f -printf "%n\n" | sort -nu | tail -n 1)
        if [ -z "$count" ]; then
            continue # no files in this pkg
        fi
        envs_count=$(echo "$count-1" | bc)
        # count = pkgs + envs
        disk_usage=$(du -sh "$pkg" | cut -f1)

        if [ "$count" -eq 1 ]; then # no env using this pkg
            echo "$envs_count,$disk_usage,,$pkg"
            continue
        fi

        # target file is any file in the pkg with the max # of hard links
        target_file=$(find "$pkg" -type f -links "$count" -print -quit)
        envs=$(
            for env in "$envs_dir"/*; do
                # https://unix.stackexchange.com/a/201922
                # find for target in each env and print env name
                # quit because at most one target in each env
                find "$env" -samefile "$target_file" -printf "$(basename "$env")\n" -quit
            done |
                # sort and join by space
                sort | paste -sd " "
        )

        # debug files
        # files=$(find "$pkg" -type f -links "$count" -print0 -quit | xargs -0 find "$conda_path" -samefile)
        # echo files:
        # echo "$files"

        echo "$envs_count,$disk_usage,$envs,$pkg"
    done
) |
    # https://stackoverflow.com/a/6075520
    # print progress during sort (by count and du)
    tee /dev/tty | sort -t',' -k1,1 -k2,2 -h | less
