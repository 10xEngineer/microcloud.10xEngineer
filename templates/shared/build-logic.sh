# shared logic

function check_root()
{
	if [ "$(id -u)" != "0" ]; then
    	echo "This script should be run as 'root'"
    	exit 1
	fi
}

function create_archive()
{
    tmpl_root=$1
    template=$2
    arch=$3

    date=`date +%Y%m%d_%H%M`

    archive_name="${template}-${arch}-${date}.tar.gz"

    cwd=`pwd`
    cd $tmpl_root

    tar -cz -f ${cwd}/dist/$archive_name ./

    cd $cwd

    echo "Archive name ${archive_name}"

    rm -f dist/${template}.tar.gz
    ln -s ${cwd}/dist/$archive_name dist/${template}.tar.gz
}

function copy_base_image()
{
	image=$1
	target=$2

	dist_image=dist/${image}.tar.gz
	echo $dist_image

	if [ ! -h dist/${image}.tar.gz ]; then
		echo "Source image $image does not exist"
		exit 1
	fi

	echo "Extracting base image."
	tar xvfz dist/$image.tar.gz -C $target >/dev/null
}
