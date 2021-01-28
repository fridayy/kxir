# kxir

*kxir* is a simple, unfinished cli with the goal to improve some common `kubectl` workflows.

## Reading all logs of a pod at once

Getting all container logs, especially init containers, is not that intuitive when using `kubectl`.
For example: `$ kubectl logs test-job-qj9q8 -c test-job-git-init` and so on

[![asciicast](https://asciinema.org/a/iJCr315PHmUX0vtWlxnmUhM2D.svg)](https://asciinema.org/a/iJCr315PHmUX0vtWlxnmUhM2D)