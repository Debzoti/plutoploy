#!/bin/sh

 gen_service(){
   podlet -f --install --overwrite --skip-services-check generate $1 $2
   podman quadlet install `$2.$1`
 }


main(){
	case "$1" in
		podman)
			podman generate systemd "$2"
			;;
		compose)
			podlet compose "$2"
			;;
		generate)
			gen_service "$2" "$3"
			;;
		container)
			podlet generate container "$2"
			;;
		pod)
			podlet generate pod "$2"
			;;
		network)
			podlet generate network "$2"
			;;
		volume)
			podlet generate volume "$2"
			;;
		image)
			podlet generate image "$2"
			;;
		help|--help|-h)
			echo "Usage: $0 <command> [args]"
			echo ""
			echo "Commands:"
			echo "  podman <name>    Generate a Podman Quadlet file from a Podman command"
			echo "  compose <file>   Generate Podman Quadlet files from a compose file"
			echo "  generate <type> <name>  Generate a Podman Quadlet file from an existing object"
			echo "  container <name> Generate a Quadlet file from an existing container"
			echo "  pod <name>       Generate Quadlet files from an existing pod and its containers"
			echo "  network <name>   Generate a Quadlet file from an existing network"
			echo "  volume <name>    Generate a Quadlet file from an existing volume"
			echo "  image <name>     Generate a Quadlet file from an image in local storage"
			echo "  help             Print this message"
			;;
		*)
			echo "Unknown command: $1" >&2
			echo "Run '$0 help' for usage."
			exit 1
			;;
	esac
}

main "$@"
