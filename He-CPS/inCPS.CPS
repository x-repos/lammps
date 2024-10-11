# choose unit system. see manual
units		metal

#Schedule
 variable   TK1 equal 3000
 variable Pbar1 equal 1.0e0

# 3d periodic system
boundary	p p p

# atoms have charge
atom_style	charge

# read the unit cell structure of alpha-quartz (3SiO2) in data.quartz file
read_data	dataCPS_5.dat
#read_restart	restart_CPS.dat
group Ca type  1
group P type 2
group Si type  3
group O type  4



# set inital velocity of particles for T=6000K
velocity	all create 3000 277387 mom yes

pair_style buck/coul/long 10.0

pair_coeff 1 1  329171.5        0.15873         4.3
pair_coeff 1 2  26684.4         0.15873         0.0
pair_coeff 1 3  164585.8        0.08000         0.0
pair_coeff 1 4  718088.6        0.163934        8.7
pair_coeff 2 2  2163.2          0.15873         0.0
pair_coeff 2 3  1081.6          0.08000         0.0
pair_coeff 2 4  62817.2         0.163934        0.0
pair_coeff 3 3  1.0e-50         1.0e50          0.0
pair_coeff 3 4  1847.7          0.287145        0.0
pair_coeff 4 4  1497594.3       0.169492        17.4

kspace_style ewald/disp 1e-4

# set neighour atom list
neighbor	0.3 bin
neigh_modify	delay 10

# nve ensemble simulaton with dt=1 fs
#fix	1 all nve
thermo		100
timestep	0.0005

#thermo_style	custom	step	temp	pxx	 pyy	pxz	....
#xy	yz	press	vol
thermo_style	custom	step	temp	press	vol	density etotal pe ke

# output trajectory to xyz file every 10 timesteps
dump 1 all xyz 50000 trajectory.xyz 
dump_modify	1 element  1 2 3 4

#compute 	1	all	msd

fix 1 all npt temp ${TK1} ${TK1} 10 iso ${Pbar1} ${Pbar1} 10

#fix 1 all nve

compute 	1	Ca 	msd
fix 2  Ca ave/time  1  1    1000  c_1[4]   file  CPS_Ca.msd
compute 	2	P 	msd
fix 3  P ave/time  1  1    1000  c_2[4]   file  CPS_P.msd

compute 	3	Si 	msd
fix 4  Si ave/time  1  1    1000  c_3[4]   file  CPS_Si.msd
compute 	4	O 	msd
fix 5  O ave/time  1  1    1000  c_4[4]   file  CPS_O.msd

run 1000

# run 200000 time steps
# run 30000000
# restart    10000000  restart_CPS.dat
# write_restart  restart_CPS.dat

