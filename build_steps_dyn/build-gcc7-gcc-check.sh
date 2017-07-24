#!/bin/bash
set -e

source /hbb_build/build-gcc7-common.sh
source /hbb_build/build-gcc7-common2.sh

activate_holy_build_box
#export PATH=/hbb/bin:$PATH

header "Check PATH gcc:"
gcc --version

header "Check HBB gcc:"
/hbb/bin/gcc --version

header "Prepare sample file..."
cat > /tmp/main.cpp << EOF
#include <iostream>
int main() {
    std::cout << "Hello, world!" << std::endl;
    return 0;
}
EOF

(
    header "Build with PATH gcc:"
  cd /tmp
  g++ -std=c++14 -o sysgcc.out main.cpp && ./sysgcc.out ; rm -f sysgcc.out
)


(
    header "Build with HBB gcc:"
  cd /tmp
  g++ -std=c++14 -o hbbgcc.out main.cpp && ./hbbgcc.out ; rm -f hbbgcc.out
)

rm -f /tmp/main.cpp
