alias git="hub"

## git
function glgd() {
	git cherry -v --abbrev $1 | grep + | grep -v maven-release-plugin
}
function _glgd() {
	for ref in $(git show-ref --heads --tags | cut -d/ -f3-); do 
		compadd $ref
	done
}
compdef _glgd glgd
