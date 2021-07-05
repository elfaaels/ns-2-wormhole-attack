# https://groups.google.com/forum/?fromgroups#!topic/ns-users/6PhzmqcApsA


# Define options
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             12                          ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
set val(x)              1400                  ;# X dimension of topography
set val(y)              100                  ;# Y dimension of topography  
set val(stop)        	10               ;# time of simulation end
 
set ns          [new Simulator]
set tracefd       [open first.tr w]
set windowVsTime2 [open win.tr w] 
set namtrace      [open first.nam w]    
 
$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)
 
 
# set up topography object
set topo       [new Topography]
 
$topo load_flatgrid $val(x) $val(y)
 
create-god $val(nn)
 
#
#  Create nn mobilenodes [$val(nn)] and attach them to the channel. 
#
 
# configure the nodes
        $ns node-config -adhocRouting $val(rp) \
             -llType $val(ll) \
             -macType $val(mac) \
             -ifqType $val(ifq) \
             -ifqLen $val(ifqlen) \
             -antType $val(ant) \
             -propType $val(prop) \
             -phyType $val(netif) \
             -channelType $val(chan) \
             -topoInstance $topo \
             -agentTrace ON \
             -routerTrace ON \
             -macTrace OFF \
             -movementTrace ON
             
    for {set i 0} {$i < $val(nn) } { incr i } {
        set node_($i) [$ns node]     
    }
#===================================
#        Nodes Definition        
#===================================
#Create 14 nodes
$node_(0) set X_ 100
$node_(0) set Y_ 400
$node_(0) set Z_ 0.0
$ns at 0.01 "$node_(0) label \"source\"" 

$node_(1) set X_ 200
$node_(1) set Y_ 600
$node_(1) set Z_ 0.0



$node_(3) set X_ 600
$node_(3) set Y_ 600
$node_(3) set Z_ 0.0

$node_(5) set X_ 1000
$node_(5) set Y_ 600
$node_(5) set Z_ 0.0

$node_(6) set X_ 1000
$node_(6) set Y_ 201
$node_(6) set Z_ 0.0

$node_(7) set X_ 1099
$node_(7) set Y_ 400
$node_(7) set Z_ 0.0

$node_(8) set X_ 800
$node_(8) set Y_ 200
$node_(8) set Z_ 0.0

$node_(9) set X_ 600
$node_(9) set Y_ 300
$node_(9) set Z_ 0.0

$node_(10) set X_ 400
$node_(10) set Y_ 201
$node_(10) set Z_ 0.0

$node_(11) set X_ 200
$node_(11) set Y_ 300
$node_(11) set Z_ 0.0
$ns at 0.01 "$node_(0) label \"destination\"" 

# configure Wormholes

		#puts "Making first wormhole"
	 	$node_(2) set X_ 400
		$node_(2) set Y_ 500
		$node_(2) set Z_ 0.0	
		$ns at 0.03 "$node_(2) label \"wh1\""

		$node_(4) set X_ 800
		$node_(4) set Y_ 500
		$node_(4) set Z_ 0.0
		$ns at 0.03 "$node_(4) label \"wh2\""

# Generation of movements
#$ns at 10.0 "$node_(0) setdest 250.0 250.0 10.0"
#$ns at 15.0 "$node_(13) setdest 45.0 285.0 10.0"
#$ns at 110.0 "$node_(0) setdest 480.0 300.0 10.0" 
#$ns at 70.0 "$node_(3) setdest 180.0 30.0 10.0" 

#===================================
#        Agents Definition        
#===================================
#Setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $node_(0) $udp
set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 1024
$cbr set interval_ 0.1


#===================================
#        Applications Definition        
#===================================
#Setup a CBR Application over UDP connection 
$cbr attach-agent $udp
set null [new Agent/Null]
$ns attach-agent $node_(7) $null
$ns connect $udp $null
$ns at 0.0 "$cbr start"
$ns at 10.0 "$cbr stop"
$ns at 0.2 "$ns trace-annotate \"Sender sends the data to the receiver through the selected router which is valid\""
$ns at 2.1 "$ns trace-annotate \"Attacker 2 and 6 forms wormhole\""





 
# Define node initial position in nam
for {set i 0} {$i < $val(nn)} { incr i } {
# 30 defines the node size for nam
$ns initial_node_pos $node_($i) 30
}
 
# Telling nodes when the simulation ends
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "$node_($i) reset";
}
 
# ending nam and the simulation 
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 150.01 "puts \"end simulation\" ; $ns halt"
proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
    #Execute nam on the trace file
    exec nam first.nam &
    exit 0
}
 
#Call the finish procedure after 5 seconds of simulation time
$ns run

