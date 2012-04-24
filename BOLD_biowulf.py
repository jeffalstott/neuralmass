n_channels = 998
n_time_steps = 1200000
memory_requirement = 4
mex_file_directory = '/home/alstottj/Code/neuralmass/'
filename = 'Hagmann'

#z = open(filename+'.m', 'w')
#z.writelines([\
#        "function BOLD_biowulf(i)\n",
#        "i = str2num(i)\n",
#        "i = i+1\n",
#        "Y = h5read('/data/alstottj/Lausanne/Hagmann_1.h5', '/V', [i 1], [1 %i]);\n" % n_time_steps,
#        "Ybold = Yall_bold(Y);\n",
#        "h5write('/data/alstottj/Lausanne/Hagmann_1.h5', '/BOLD', Ybold, [i 1], [1 %i])" % n_time_steps
#        ])
#z.close()
#
#from os import system
#system("mcc -m "+filename+'.m')

import biowulf
swarm = biowulf.Swarm(memory_requirement=memory_requirement)
for i in range(n_channels):
    print i
    job_string = mex_file_directory+"run_%s.sh /usr/local/matlab64 %i" % (filename, i)
    swarm.add_job(job_string, no_python=True)

swarm.submit()


