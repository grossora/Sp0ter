import sys, os 
import shutil
import subprocess

#if len(sys.argv)<1:
 #   print 'you need to enter a directory'
# Get the directory 
cwd = os.getcwd() 

#remove data directory 
dd = cwd + '/data'
if os.path.exists(dd):
    shutil.rmtree(cwd+'/data')

#os.makedirs(cwd+'/data')

shutil.copytree(cwd+'/'+sys.argv[1],dd)
#for f in sys.argv[1:]:
 #   print f
  #  shutil.copytree(f,dd)

# now make the zip
subprocess.call('zip -r newzip data',shell=True)




