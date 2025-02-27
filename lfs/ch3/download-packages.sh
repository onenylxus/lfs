# #!/bin/bash

mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources

clean()
{
  rm -rf wget-list-sysv md5sums *.tar.* *.patch
}

pdlchk()
{
  pushd $SOURCES > /dev/null

  if md5sum -c md5sums
  then
    mv * $LFS/sources
    clean
    popd > /dev/null
    echo "OK:    predownload source packages found"
    chown root:root $LFS/sources/*
    exit 0
  fi

  popd > /dev/null
}

dlpkg()
{
  pushd $LFS/sources > /dev/null

  clean
  wget --timestamping "https://www.linuxfromscratch.org/lfs/view/$1/wget-list-sysv"
  wget --timestamping --input-file=wget-list-sysv --continue --directory-prefix=$LFS/sources
  wget --timestamping "https://www.linuxfromscratch.org/lfs/view/$1/md5sums"
  check

  popd > /dev/null
}

check()
{
  if md5sum -c md5sums
  then
    popd > /dev/null
    echo "OK:    downloaded source packages"
    chown root:root $LFS/sources/*
    exit 0
  fi
}

pdlchk
while IFS= read -r option
do
  dlpkg "$option"
done < $SOURCES/options.txt

echo "ERROR: source packages failed to verify"
exit 1
