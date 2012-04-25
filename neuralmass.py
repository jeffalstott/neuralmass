def matlab2biowulf_H5(data_filename,
        memory_requirement = 4,
        mex_file_directory = '/home/alstottj/Code/neuralmass/',
        mex_filename = 'V2BOLD_H5',
        variable = 'V',
        channels = None,
        run_id = None,
        duration = None):

    if variable and not channels:
        import h5py
        f = h5py.File(data_filename)
        n_time_steps, n_channels = f[variable].shape
        channels = range(1,n_channels+1)

    import biowulf
    swarm = biowulf.Swarm(memory_requirement=memory_requirement)
    if variable:
        for i in channels:
            print i
            job_string = mex_file_directory+"run_%s.sh /usr/local/matlab64 %i %s" % (mex_filename, i, data_filename)
            swarm.add_job(job_string, no_python=True)
    elif run_id and duration:
        job_string = mex_file_directory+"run_%s.sh /usr/local/matlab64 %i %s %i" % (mex_filename, run_id, data_filename, duration)
        swarm.add_job(job_string, no_python=True)
    elif run_id:
        job_string = mex_file_directory+"run_%s.sh /usr/local/matlab64 %i %s" % (mex_filename, run_id, data_filename)
        swarm.add_job(job_string, no_python=True)
    else:
        job_string = mex_file_directory+"run_%s.sh /usr/local/matlab64 %s" % (mex_filename, data_filename)
        swarm.add_job(job_string, no_python=True)

    swarm.submit()


