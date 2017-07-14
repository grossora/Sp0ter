import sys, os 
from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

# we'd better have Cython installed, or it's a no-go
try:
    from Cython.Distutils import build_ext
except:
    print("You don't seem to have Cython installed. Please get a")
    print("copy from www.cython.org and install it")
    sys.exit(1)


toppath = os.getcwd()
print toppath
sys.path.insert(0, toppath)
apppath = os.path.join(toppath,'app')
libpath = os.path.join(toppath,'lib')

#Run Make for Spacecharge 

scpath = os.path.join(toppath,'app/utility/SpaceCharge')
import subprocess 

os.chdir(scpath)
pro = subprocess.Popen(["make","spoter"])
pro.wait()
proc = subprocess.Popen(["make","clean2"])
proc.wait()

# Get back to the top
os.chdir(toppath)
############################################
############################################

# scan directories 
def scandir(dir):
    files = []
    for file in os.listdir(dir):
        path = os.path.join(dir, file)
        if os.path.isfile(path) and path.endswith(".pyx"):
            files.append(path)
            #files.append(path.replace(os.path.sep, ".")[:-4])
        elif os.path.isdir(path):
            files.append(scandir(path))
    return files

# Clean out the .c
def cleandir(dir):
    for file in os.listdir(dir):
        path = os.path.join(dir, file)
        if os.path.isfile(path) and path.endswith(".c"):
            os.remove(path)
        elif os.path.isdir(path):
            cleandir(path)
    return 

# Make inits 
def make_init(dir):
    for s in os.listdir(dir):
        path = os.path.join(dir, s)
	# Drop an init
	if os.path.isdir(path):
	    make_init(path)
    f = open("{}/__init__.py".format(dir),"a+")
    f.close()
    return

# First build the extenstion for Utilites
def make_ext(EN):
    extName = EN.split("app/")[1]
    extLName = 'lib.'+extName.replace("/",".").rsplit(".",1)[0]
    return Extension(
        extLName,
        [EN],
        #include_dirs = [libdvIncludeDir, "."],   # adding the '.' to include_dirs is CRUCIAL!!
        #extra_compile_args = ["-O3", "-Wall"],
        #extra_link_args = ['-g'],
        #libraries = ["dv",],
        )
make_init(libpath)






##################################
##################################
##################################



##################################
# Geo_Utils
##################################
print 'starting the utility build'
tutil_extNames = scandir(os.path.join(apppath,"utility"))
util_extNames = [item for sublist in tutil_extNames for item in sublist]
#print util_extNames
extensions = [make_ext(name) for name in util_extNames]
#print extensions
# Build this and make the same directory structor as app

setup(
  name="utility",
  ext_modules = cythonize(extensions),
)

#setup(
#  name="utility",
#      packages=find_packages(),
#      cmdclass = {'build_ext': build_ext},
#      ext_modules = extensions,
#)
make_init(libpath)


##################################
# Clustering 
##################################
print 'starting the cluster build'
print os.path.join(apppath,"Clustering")
clust_extNames = scandir(os.path.join(apppath,"Clustering"))
if len(clust_extNames)>1:
    clust_extNames = [item for sublist in clust_extNames for item in sublist]
# Since this is multilevel directory
clust_extensions = [make_ext(name) for name in clust_extNames]
# Build this and make the same directory structor as app

setup(
  name="cluster",
  ext_modules = cythonize(clust_extensions)
)
 
#setup(
#  name="cluster",
#      packages=find_packages(),
#      cmdclass = {'build_ext': build_ext},
#      ext_modules = clust_extensions,
#)
make_init(libpath)
##################################
##################################

##################################
print 'starting the Merge build'
print os.path.join(apppath,"Merging")
merge_extNames = scandir(os.path.join(apppath,"Merging"))
#if len(merge_extNames)>1:
#    merge_extNames = [item for sublist in merge_extNames for item in sublist]
merge_extensions = [make_ext(name) for name in merge_extNames]
# Build this and make the same directory structor as app

setup(
  name="merge",
  ext_modules = cythonize(merge_extensions)
)
make_init(libpath)
##################################
##################################


##################################
print 'starting the TS_Qual build'
print os.path.join(apppath,"TS_Qual")
tsqual_extNames = scandir(os.path.join(apppath,"TS_Qual"))
#if len(merge_extNames)>1:
#    merge_extNames = [item for sublist in merge_extNames for item in sublist]
tsqual_extensions = [make_ext(name) for name in tsqual_extNames]
# Build this and make the same directory structor as app

setup(
  name="ts_qual",
  ext_modules = cythonize(tsqual_extensions)
)
make_init(libpath)
##################################
##################################


##################################
print 'starting the SParams build'
print os.path.join(apppath,"TS_Qual")
sparams_extNames = scandir(os.path.join(apppath,"SParams"))
#if len(merge_extNames)>1:
#    merge_extNames = [item for sublist in merge_extNames for item in sublist]
sparams_extensions = [make_ext(name) for name in sparams_extNames]
# Build this and make the same directory structor as app

setup(
  name="sparams",
  ext_modules = cythonize(sparams_extensions)
)
make_init(libpath)
##################################
##################################

##################################
print 'starting the Selection build'
print os.path.join(apppath,"Selection")
selection_extNames = scandir(os.path.join(apppath,"Selection"))
#if len(merge_extNames)>1:
#    merge_extNames = [item for sublist in merge_extNames for item in sublist]
selection_extensions = [make_ext(name) for name in selection_extNames]
# Build this and make the same directory structor as app
setup(
  name="selection",
  ext_modules = cythonize(selection_extensions)
)
make_init(libpath)
##################################
##################################










##################################
#print ' now we clean up '
#extNames = cleandir(os.path.join(apppath,"utility"))
#extNames = cleandir(os.path.join(apppath,"Clustering"))
#extNames = cleandir(os.path.join(apppath,"Merging"))
#extNames = cleandir(os.path.join(apppath,"TS_Qual"))
#extNames = cleandir(os.path.join(apppath,"SParams"))
#extNames = cleandir(os.path.join(apppath,"Selection"))
print 'done '
# Make the inits for the libs

#extNames = cleandir(os.path.join(apppath,"utility"))
