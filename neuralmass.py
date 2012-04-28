from Helix import biowulf

def sim_function2biowulf(CIJ_filename,
        run_id,
        duration,
        memory_requirement = 72,
        mex_file_directory = '/data/LesionedBrains/neuralmass/',
        mex_filename = 'sim_function'):

    dir, filename = CIJ_filename.rsplit('/',1)
    dir = dir+'/'
    swarm = biowulf.Swarm(memory_requirement=memory_requirement)
    job_string = mex_file_directory+"run_%s.sh /usr/local/matlab64 %i %i %s %s" % (mex_filename, duration, run_id, filename, dir)
    swarm.add_job(job_string, no_python=True)
    swarm.submit()

    if filename[-3:]=='.h5':
        sim_filename = dir+'sim'+str(run_id)+'_'+filename
    else:
        sim_filename = dir+'sim'+str(run_id)+'_'+filename+'.h5'

    return sim_filename


def V2BOLD2biowulf(sim_filename,
        channels = None,
        memory_requirement = 4,
        mex_file_directory = '/data/LesionedBrains/neuralmass/',
        mex_filename = 'V2BOLD',
        variable = 'V'):

    if not channels:
        import h5py
        f = h5py.File(sim_filename)
        n_time_steps, n_channels = f[variable].shape
        channels = range(n_channels)

    dir, sim_filename = sim_filename.rsplit('/',1)
    dir = dir+'/'

    swarm = biowulf.Swarm(memory_requirement=memory_requirement)
    for i in channels:
        print i
        job_string = mex_file_directory+"run_%s.sh /usr/local/matlab64 %i %s %s" % (mex_filename, i, sim_filename, dir)
        swarm.add_job(job_string, no_python=True)

    swarm.submit()

def combineBOLD(sim_filename,
        channels = None):

    dir, sim_filename = sim_filename.rsplit('/',1)
    dir = dir+'/'
    from os import listdir, remove
    dirfiles = listdir(dir)
    if not channels:
        channels = []
        for i in dirfiles:
            if i.startswith('BOLDchan') and i.endswith(sim_filename):
                channels.append(int(i.split('_')[0][8:]))

    import h5py
    B = h5py.File(dir+'BOLDchan'+str(channels[0])+'_'+sim_filename)['BOLD']
    f = h5py.File(dir+'BOLD_'+sim_filename)
    if 'BOLD' not in list(f):
        from numpy import empty, max
        f['BOLD'] = empty((max(channels)+1,len(B)))

    for i in channels:
        B = h5py.File(dir+'BOLDchan'+str(i)+'_'+sim_filename)['BOLD'][:,:]
        f['BOLD'][i] = B.flatten()

    f.close()
    for i in dirfiles:
        if i.startswith('BOLD') and i.endswith(sim_filename):
            remove(dir+i)
