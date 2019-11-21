jointNames = {
    'ThighJoint_Front_Right',
    'KneeJoint_Front_Right',
    'LowerLeg_Front_Right',

    'ThighJoint_Front_Right0',
    'KneeJoint_Front_Right0',
    'LowerLeg_Front_Right0',

    'ThighJoint_Front_Right1',
    'KneeJoint_Front_Right1',
    'LowerLeg_Front_Right1',

    'ThighJoint_Front_Right2',
    'KneeJoint_Front_Right2',
    'LowerLeg_Front_Right2'
}

trotParams = {
    {0, 0.3, 0},
    {0, 0.0, 1.5},
    {0, 0, 0},

    {0, 0.3, 1},
    {0, 0.3, 0.5},
    {0, 0, 0},
    
    {0, 0.3, 1},
    {0, 0.3, 1.5},
    {0, 0, 0},
    
    {0, 0.3, 0},
    {0, 0.0, 0.5},
    {0, 0, 0}
}

omega = 2*math.pi

stop, straight, right, left = 0, 1, 2, 3

state = stop

function sysCall_init()
    handles = {}
    for i = 1,12 do
        handles[i] = sim.getObjectHandle(jointNames[i])
    end

    baseVisionSensor = sim.getObjectHandle('base_vision_sensor')
    
    pub=simROS.advertise('/image', 'sensor_msgs/Image')
    simROS.publisherTreatUInt8ArrayAsString(pub)

    sub=simROS.subscribe('/alg_ctrl', 'std_msgs/Int8', 'alg_ctrl_callback')
end

function sysCall_actuation()
    if state == stop then
        for i=1,12 do sim.setJointTargetPosition(handles[i],0) end
        return
    elseif state == straight then
        trotParams[1][2] = 0.3
        trotParams[4][2] = 0.3
        trotParams[7][2] = 0.3
        trotParams[10][2] = 0.3
    elseif state == right then
        trotParams[1][2] = 0.0
        trotParams[4][2] = 0.0
        trotParams[7][2] = 0.3
        trotParams[10][2] = 0.3
    elseif state == left then
        trotParams[1][2] = 0.3
        trotParams[4][2] = 0.3
        trotParams[7][2] = 0.0
        trotParams[10][2] = 0.0
    end

    for i=1,12 do
        angle = trotParams[i][1] + trotParams[i][2]*math.sin(omega*sim.getSimulationTime() + trotParams[i][3]*math.pi)
        sim.setJointTargetPosition(handles[i],angle)
    end
end

function sysCall_sensing()
    local data,w,h=sim.getVisionSensorCharImage(baseVisionSensor)
    d={}
    d['header']={seq=0,stamp=simROS.getTime(), frame_id="a"}
    d['height']=h
    d['width']=w
    d['encoding']='rgb8'
    d['is_bigendian']=1
    d['step']=w*3
    d['data']=data
    simROS.publish(pub,d)
end

function alg_ctrl_callback(msg)
    state = msg.data
end
