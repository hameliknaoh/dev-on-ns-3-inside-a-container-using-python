# Develop and Prototype Networking Simulations on NS-3 Using Python

The discrete-event network simulator [ns-3](https://www.nsnam.org/) is widely used by both the research and the industry communities to prototype and experiment on networking protocols and systems e.g. [Deadline-Aware Datacenter TCP (D2TCP) (Sigcomm'12)](https://ai.google/research/pubs/pub37678) and [DeTail: Reducing the Flow Completion Time Tail in Datacenter Networks (Sigcomm'12)](https://research.fb.com/publications/detail-reducing-the-flow-completion-time-tail-in-datacenter-networks/).

`ns-3` has been initially designed and built to be used primarily in c++. Although c++ allows `ns-3` developers to hook at the bare metal of the simulator system as well as the linux operating-system host :metal:, it makes the prototyping process relatively slow :watch::turtle: and tedious :mag::beetle:. Recently, `ns-3` maintainers [proposed to leverage the versatility of python and enable python development on ns-3](https://www.nsnam.org/docs/manual/html/python.html) to speed up the prototyping cycle :bulb:.

Developing with python in `ns-3` [relies on scanning the ns-3 c++ modules and generate their respective python bindings](https://www.nsnam.org/wiki/Python_bindings). The generation of python bindings in `ns-3` is still a work-in-progress, and it requires some extra effort at the developer side to manually build and successfully mix, match and integrate the required libraries for the scanning process. I never say no to build, and I burned some of my saved energy :coffee::fuelpump: and my late-night candles :hourglass_flowing_sand::dizzy: getting the `ns-3` python-bindings pipeline-generation built. I am shipping [a ready-to-use docker image :whale: for ns-3 (version 3.26)](https://hub.docker.com/r/hamelik/ns3.26libdependencies/) for python development on my docker hub. Feel free to give it a try! For any modification of the `ns-3` c++ API, please issue the command `./waf --apiscan=all` from the `ns-3` home project, to generate the corresponding python bindings.

I will be also providing docker images to automate the python bindings generation for the upcoming [ns-3 releases (version >= 3.26)](https://www.nsnam.org/releases/older/). I hope you find this useful :spades::hearts::clubs::diamonds::gem:! Happy coding :grin: and peace out! :v:

# System Requirements and Setup

Going ahead, we will be setting up our ns-3 docker box on a Linux environment. The attached `build-script.sh` to the repository has been tested on a `Ubuntu-18.04` machine with the `zsh` interpreter, but it should also work fine for the rest of Debian and Ubuntu-based Linux distributions that are supported by Docker Inc.: for more details, please check [the list of Linux platforms supported by Docker Inc](https://docs.docker.com/install/#supported-platforms). Clone the `git` repository, and start running the `build-script.sh` to update the system packages, install docker and pull [my ns-3 docker image](https://hub.docker.com/r/hamelik/ns3.26libdependencies/) from the Docker Hub:

```
  $ git clone https://github.com/hameliknaoh/dev-on-ns-3-using-python.git
  $ cd dev-on-ns-3-using-python/
  $ ./build-script.sh
```

To verify that the setup process was successfull, we should be able to have the `hamelik/ns3.26libdependencies` docker image listed when the command `docker images` is issued:

```
  $ docker imgaes

  REPOSITORY                      TAG                 IMAGE ID            CREATED             SIZE
  hamelik/ns3.26libdependencies   first               c53ffa37a8e1        9 months ago        4.1GB
```

To start an `ns-3 docker container` for development and API scanning with python, we will be using the `hamelik/ns3.26libdependencies` docker image, and we will issuing the command `docker run`. Let's call our ns-3 docker container `Hello-NS-3.26`:

```
  $ docker run -it --name Hello-NS-3.26 hamelik/ns3.26libdependencies:first /bin/bash
```

The `ns-3.26 home directory` is located under `/home/ns-allinone-3.26/ns-3.26`. Navigate under this path using the `cd` command, and you will be able to list the following items, in particular, the `waf` build automation tool:

```
  # cd /home/ns-allinone-3.26/ns-3.26/
  # ls -a
  
  .                                             LICENSE        build     testpy-output  waf-tools
  ..                                            Makefile       doc       testpy.supp    waf.bat
  .lock-waf_linux2_build                        README         examples  utils          wscript
  .waf-1.8.19-b1fc8f7baef51bd2db4c2971909a568d  RELEASE_NOTES  scratch   utils.py       wutils.py
  AUTHORS                                       VERSION        src       utils.pyc      wutils.pyc
  CHANGES.html                                  bindings       test.py   waf
```

# Configure, Build and Run Python Simulations in NS-3
`ns-3` could be configured to be built with a `debug`, `release` or `optimized` [profile](https://www.nsnam.org/docs/tutorial/html/getting-started.html#build-profiles). In this guide, we will be developing with the `debug` profile. From the `ns-3.26 home directory`, we get the network simulator ready for developping following these four steps:

## Step 1: Clean the previous build (optional, but a good practice)
```
  # cd /home/ns-allinone-3.26/ns-3.26/
  # ./waf clean
  
  'clean' finished successfully (0.191s)
```

## Step 2: Configure the project
```
  # ./waf configure --build-profile=debug --enable-examples --enable-tests
```

<details>
<summary>
  <pre>
    'configure' finished successfully (2.262s)
  </pre>
</summary>
<p>
Setting top to                           : /home/ns-allinone-3.26/ns-3.26 <br>
Setting out to                           : /home/ns-allinone-3.26/ns-3.26/build <br>
Checking for 'gcc' (C compiler)          : /usr/bin/gcc <br>
Checking for cc version                  : 4.9.4 <br>
Checking for 'g++' (C++ compiler)        : /usr/bin/g++ <br>
Checking for compilation flag -Wl,--soname=foo support : ok <br>
Checking for program 'python'                          : /usr/bin/python <br>
Checking for python version                            : (2, 7, 6, 'final', 0) <br> 
python-config                                          : /usr/bin/python-config <br>
Asking python-config for pyembed '--cflags --libs --ldflags' flags : yes <br>
Testing pyembed configuration                                      : yes <br>
Asking python-config for pyext '--cflags --libs --ldflags' flags   : yes <br>
Testing pyext configuration                                        : yes <br>
Checking for compilation flag -fvisibility=hidden support          : ok <br>
Checking for compilation flag -Wno-array-bounds support            : ok <br>
Checking for pybindgen location                                    : ../pybindgen-0.17.0.post57+nga6376f2 (guessed) <br>
Checking for python module 'pybindgen'                             : 0.17.0.post57+nga6376f2 <br>
Checking for pybindgen version                                     : 0.17.0.post57+nga6376f2 <br>
Checking for code snippet                                          : yes <br>
Checking for types uint64_t and unsigned long equivalence          : no <br>
Checking for code snippet                                          : no <br>
Checking for types uint64_t and unsigned long long equivalence     : yes <br>
Checking for the apidefs that can be used for Python bindings      : gcc-LP64 <br> 
Checking for internal GCC cxxabi                                   : complete <br>
Checking for python module 'pygccxml'                              : 1.0.0 <br>
Checking for pygccxml version                                      : 1.0.0 <br>
Checking for program 'gccxml'                                      : /usr/bin/gccxml <br>
Checking for gccxml version                                        : 0.9.0 <br>
Checking boost includes                                            : headers not found, please provide a --boost-includes argument (see help) <br>
Checking boost includes                                            : headers not found, please provide a --boost-includes argument (see help) <br>
Checking for click location                                        : not found <br>
Checking for program 'pkg-config'                                  : /usr/bin/pkg-config <br>
Checking for 'gtk+-2.0' >= 2.12                                    : yes <br>
Checking for 'libxml-2.0' >= 2.7                                   : yes <br>
Checking for type uint128_t                                        : not found <br>
Checking for type __uint128_t                                      : yes <br>
Checking high precision implementation                             : 128-bit integer (default) <br>
Checking for header stdint.h                                       : yes <br>
Checking for header inttypes.h                                     : yes <br>
Checking for header sys/inttypes.h                                 : not found <br>
Checking for header sys/types.h                                    : yes <br>
Checking for header sys/stat.h                                     : yes <br>
Checking for header dirent.h                                       : yes <br>
Checking for header stdlib.h                                       : yes <br>
Checking for header signal.h                                       : yes <br>
Checking for header pthread.h                                      : yes <br>
Checking for header stdint.h                                       : yes <br>
Checking for header inttypes.h                                     : yes <br>
Checking for header sys/inttypes.h                                 : not found <br>
Checking for library rt                                            : yes <br>
Checking for header sys/ioctl.h                                    : yes <br>
Checking for header net/if.h                                       : yes <br>
Checking for header net/ethernet.h                                 : yes <br>
Checking for header linux/if_tun.h                                 : yes <br>
Checking for header netpacket/packet.h                             : yes <br>
Checking for NSC location                                          : not found <br>
Checking for 'sqlite3'                                             : yes <br>
Checking for header linux/if_tun.h                                 : yes <br>
Checking for python module 'gtk'                                   : ok <br>
Checking for python module 'goocanvas'                             : 0.14.1 <br>
Checking for python module 'pygraphviz'                            : 1.2 <br>
Checking for program 'sudo'                                        : /usr/bin/sudo <br>
Checking for program 'valgrind'                                    : /usr/bin/valgrind <br>
Checking for 'gsl'                                                 : yes <br>
python-config                                                      : not found <br>
Checking for compilation flag -Wno-error=deprecated-d... support   : ok <br>
Checking for compilation flag -Wno-error=deprecated-d... support   : ok <br>
Checking for compilation flag -fstrict-aliasing support            : ok <br>
Checking for compilation flag -fstrict-aliasing support            : ok <br>
Checking for compilation flag -Wstrict-aliasing support            : ok <br>
Checking for compilation flag -Wstrict-aliasing support            : ok <br>
Checking for program 'doxygen'                                     : /usr/bin/doxygen <br>
---- Summary of optional NS-3 features:<br>
Build profile                 : debug <br>
Build directory               : <br>
BRITE Integration             : not enabled (BRITE not enabled (see option --with-brite)) <br>
DES Metrics event collection  : not enabled (defaults to disabled) <br>
Emulation FdNetDevice         : enabled <br>
Examples                      : enabled <br>
File descriptor NetDevice     : enabled <br>
GNU Scientific Library (GSL)  : enabled <br>
Gcrypt library                : not enabled (libgcrypt not found: you can use libgcrypt-config to find its location.) <br>
GtkConfigStore                : enabled <br>
MPI Support                   : not enabled (option --enable-mpi not selected) <br>
NS-3 Click Integration        : not enabled (nsclick not enabled (see option --with-nsclick)) <br>
NS-3 OpenFlow Integration     : not enabled (Required boost libraries not found) <br>
Network Simulation Cradle     : not enabled (NSC not found (see option --with-nsc)) <br>
PlanetLab FdNetDevice         : not enabled (PlanetLab operating system not detected (see option --force-planetlab)) <br>
PyViz visualizer              : enabled <br>
Python API Scanning Support   : enabled <br>
Python Bindings               : enabled <br>
Real Time Simulator           : enabled <br>
SQlite stats data output      : enabled <br>
Tap Bridge                    : enabled <br>
Tap FdNetDevice               : enabled <br>
Tests                         : enabled <br>
Threading Primitives          : enabled <br>
Use sudo to set suid bit      : not enabled (option --enable-sudo not selected) <br>
XmlIo                         : enabled <br>
'configure' finished successfully (2.262s) <br>
</p>
</details>

## Step 3: Build the project
```
  # ./waf build
```

<details>
<summary>
  <pre>
    'build' finished successfully (7m25.441s)
  </pre>
</summary>
<p>
Waf: Entering directory `/home/ns-allino  ne-3.26/ns-3.26/build' <br>
[   1/2631] Compiling install-ns3-header: ns3/antenna-model.h <br>
[   2/2631] Compiling install-ns3-header: ns3/isotropic-antenna-model.h <br>
[   4/2631] Compiling install-ns3-header: ns3/angles.h <br>
[   5/2631] Compiling install-ns3-header: ns3/parabolic-antenna-model.h <br>
[   5/2631] Compiling install-ns3-header: ns3/cosine-antenna-model.h <br>
[   6/2631] Processing command (${PYTHON}): ../bindings/python/ns3modulegen-modular.py ../src/antenna/bindings/modulegen__gcc_LP64.py -> src/antenna/bindings/ns3module.cc src/antenna/bindings/ns3module.h src/antenna/bindings/ns3modulegen.log  <br>

[   7/2631] Compiling install-ns3-header: ns3/aodv-packet.h <br>
[   8/2631] Compiling install-ns3-header: ns3/aodv-neighbor.h <br>
[   9/2631] Compiling install-ns3-header: ns3/aodv-rqueue.h <br>
[  10/2631] Compiling install-ns3-header: ns3/aodv-routing-protocol.h <br>
[  11/2631] Compiling install-ns3-header: ns3/aodv-rtable.h <br>
[  12/2631] Compiling install-ns3-header: ns3/aodv-id-cache.h <br>
[  14/2631] Compiling install-ns3-header: ns3/aodv-dpd.h <br>
[  14/2631] Compiling install-ns3-header: ns3/aodv-helper.h <br>
[  15/2631] Processing command (${PYTHON}): ../bindings/python/ns3modulegen-modular.py ../src/aodv/bindings/modulegen__gcc_LP64.py -> src/aodv/bindings/ns3module.cc src/aodv/bindings/ns3module.h src/aodv/bindings/ns3modulegen.log <br>
 <br>
    ... <br>
    ... <br>
 <br>
[2619/2631] Linking build/bindings/python/ns/point_to_point.so <br>
[2620/2631] Linking build/utils/ns3.26-test-runner-debug <br>
[2622/2631] Compiling src/fd-net-device/helper/encode-decode.cc <br>
[2622/2631] Compiling src/fd-net-device/helper/tap-device-creator.cc <br>
[2623/2631] Compiling src/fd-net-device/helper/creator-utils.cc <br>
[2624/2631] Linking build/src/fd-net-device/ns3.26-tap-device-creator-debug <br>
[2625/2631] Compiling src/fd-net-device/helper/raw-sock-creator.cc <br>
[2626/2631] Compiling src/fd-net-device/helper/encode-decode.cc <br>
[2627/2631] Compiling src/fd-net-device/helper/creator-utils.cc <br>
[2628/2631] Linking build/src/fd-net-device/ns3.26-raw-sock-creator-debug <br>
[2629/2631] Compiling src/tap-bridge/model/tap-creator.cc <br>
[2630/2631] Compiling src/tap-bridge/model/tap-encode-decode.cc <br>
[2631/2631] Linking build/src/tap-bridge/ns3.26-tap-creator-debug <br>
Waf: Leaving directory `/home/ns-allinone-3.26/ns-3.26/build' <br>
Build commands will be stored in build/compile_commands.json <br>
'build' finished successfully (7m25.441s) <br>
 <br>
Modules built: <br>
antenna                   aodv                      applications               <br>
bridge                    buildings                 config-store               <br>
core                      csma                      csma-layout                <br>
dsdv                      dsr                       energy                     <br>
fd-net-device             flow-monitor              internet                   <br>
internet-apps             lr-wpan                   lte                        <br>
mesh                      mobility                  mpi                        <br>
netanim (no Python)       network                   nix-vector-routing         <br>
olsr                      point-to-point            point-to-point-layout      <br>
propagation               sixlowpan                 spectrum                   <br>
stats                     tap-bridge                test (no Python)           <br>
topology-read             traffic-control           uan                        <br>
virtual-net-device        visualizer                wave                       <br>
wifi                      wimax                      <br>
 <br>
Modules not built (see ns-3 tutorial for explanation): <br>
brite                     click                     openflow <br>
</p>
</details> 

## Step 4: Run Your First Python Simulation Script in NS-3
The `ns-3` distribution is initially shipped with three python simulation scripts `first.py`, `second.py`, and `third.py`, that are located under `examples/tutorial/`. Let's run the first script that is simulating an echo message exchange between a client and a server.

```
  # cd /home/ns-allinone-3.26/ns-3.26/
  # ./waf --pyrun examples/tutorial/first.py
  
  Waf: Entering directory `/home/ns-allinone-3.26/ns-3.26/build'
  Waf: Leaving directory `/home/ns-allinone-3.26/ns-3.26/build'
  Build commands will be stored in build/compile_commands.json
  'build' finished successfully (2.054s)

  Modules built:
  antenna                   aodv                      applications              
  bridge                    buildings                 config-store              
  core                      csma                      csma-layout               
  dsdv                      dsr                       energy                    
  fd-net-device             flow-monitor              internet                  
  internet-apps             lr-wpan                   lte                       
  mesh                      mobility                  mpi                       
  netanim (no Python)       network                   nix-vector-routing        
  olsr                      point-to-point            point-to-point-layout     
  propagation               sixlowpan                 spectrum                  
  stats                     tap-bridge                test (no Python)          
  topology-read             traffic-control           uan                       
  virtual-net-device        visualizer                wave                      
  wifi                      wimax                     

  Modules not built (see ns-3 tutorial for explanation):
  brite                     click                     openflow                  

  At time 2s client sent 1024 bytes to 10.1.1.2 port 9
  At time 2.00369s server received 1024 bytes from 10.1.1.1 port 49153
  At time 2.00369s server sent 1024 bytes to 10.1.1.1 port 49153
  At time 2.00737s client received 1024 bytes from 10.1.1.2 port 9
```

# NS-3 C++ API Scanning and Python Module Generation
To test that the ns-3 c++ api scanning is properly working, issue the command

```
  # ./waf --apiscan=all
```

The `./waf --apiscan=all` automation tool will be scanning `all` the ns-3 modules

```
  Waf: Entering directory `/home/ns-allinone-3.26/ns-3.26/build'
  Modules to scan:  ['antenna', 'aodv', 'applications', 'bridge', 'buildings', 'config-store', 
                      'core', 'csma', 'csma-layout', 'dsdv', 'dsr', 'energy', 'fd-net-device', 
                      'flow-monitor', 'internet', 'internet-apps', 'lr-wpan', 'lte', 'mesh', 
                      'mobility', 'mpi', 'network', 'nix-vector-routing', 'olsr', 'point-to-point', 
                      'point-to-point-layout', 'propagation', 'sixlowpan', 'spectrum', 'stats', 
                      'tap-bridge', 'topology-read', 'traffic-control', 'uan', 'virtual-net-device', 
                      'visualizer', 'wave', 'wifi', 'wimax']
```

When `waf` is done scanning, a green message will be outputted in the terminal specifying the operation duration as well as the successfully built modules.

```
  Waf: Leaving directory `/home/ns-allinone-3.26/ns-3.26/build'
  Build commands will be stored in build/compile_commands.json
  'build' finished successfully (19m42.182s)

  Modules built:
  antenna                   aodv                      applications              
  bridge                    buildings                 config-store              
  core                      csma                      csma-layout               
  dsdv                      dsr                       energy                    
  fd-net-device             flow-monitor              internet                  
  internet-apps             lr-wpan                   lte                       
  mesh                      mobility                  mpi                       
  netanim (no Python)       network                   nix-vector-routing        
  olsr                      point-to-point            point-to-point-layout     
  propagation               sixlowpan                 spectrum                  
  stats                     tap-bridge                test (no Python)          
  topology-read             traffic-control           uan                       
  virtual-net-device        visualizer                wave                      
  wifi                      wimax                     

  Modules not built (see ns-3 tutorial for explanation):
  brite                     click                     openflow 
```
If a specific module with the name `my_module` has only been changed, it can be scanned as follows: this will obviously help to cut down the scanning process execution time.

```
  # ./waf --apiscan=my_module
```

It is completely possible to detach and re-attach to the `Hello-NS-3.26` docker container at any time:
   * To detach from the `Hello-NS-3.26` docker container, you can use the shortcut `ctrl+p ctrl+q`
   * To re-attach, you can issue the command `docker attach Hello-NS-3.26`
   * To kill the docker container, detach first and then issue the command `docker kill Hello-NS-3.26`
