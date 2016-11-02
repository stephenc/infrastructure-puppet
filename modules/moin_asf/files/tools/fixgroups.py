#!/usr/bin/env python
"""
contributor and admin group culler. Checks if the users exist, and if
not, removes them from their respective groups by writing a new
group file.

usage: python fixgroups.py --data /www/wiki/data (or whatevs)
"""

import os, sys, re, time
from os import listdir
from os.path import isfile, join, isdir
import argparse

# dir/file shortcuts
def files(mypath):
    return [f for f in listdir(mypath) if isfile(join(mypath, f))]
    
def dirs(mypath):
    return [f for f in listdir(mypath) if isdir(join(mypath, f))]

# list of users
active_users = {}
all_users = {}

# args
parser = argparse.ArgumentParser()
parser.add_argument("--data", type= str, help = "Base moin wiki data directory")
parser.add_argument("--shared", type= str, help = "Optional shared (global) moin data dir")

args = parser.parse_args()

if args.data:
    wikis = dirs(args.data)
else:
    print("Please specify the data dir (/wwww/wiki/data or some such)!")
    sys.exit(-1)

globdir = None
if args.shared:
    globdir = args.shared

# For each wiki, ...
for wiki in wikis:
    
    # Reset user list
    allusers = []
    
    # If share lib is specified, include it
    if globdir:
        for f in files("%s/user/" % globdir):
            allusers.append("%s/user/%s" % (globdir, f))
            
    # If local userbase exists, include it
    if os.path.exists(("%s/%s/data/user/" % (args.data, wiki))):
        for f in files("%s/%s/data/user/" % (args.data, wiki)):
            allusers.append("%s/%s/data/user/%s" % (args.data, wiki, f))
        
    # Get ALL users, local + global
    AU = []
    for filename in allusers:
        with open(filename, "r") as f:
            d = f.read()
            f.close()
            m = re.search(r"name=([^\r\n]+)", d)
            if m:
                n = m.group(1).lower()
                AU.append(n)
                
    # ContributorsGroup
    contribs = []
    if os.path.exists("%s/%s/data/pages/ContributorsGroup/current" % (args.data, wiki)):
        afile = None
        i = 0
        actives = []
        # Get the last revision of the contributors group (alphasort, pick [-1])
        if os.path.isdir("%s/%s/data/pages/ContributorsGroup/revisions/" % (args.data, wiki)):
            rv = files("%s/%s/data/pages/ContributorsGroup/revisions/" % (args.data, wiki))
            lastfile = sorted(rv)[-1]
            afile = "%s/%s/data/pages/ContributorsGroup/revisions/%s" % (args.data, wiki, lastfile)
            # Open last revision, find all users listed
            with open(afile) as f:
                d = f.read()
                for match in re.finditer(r"\s*\*\s+\[*([^\r\n\]]+)", d):
                    name = match.group(1)
                    if name.lower() != "admingroup":
                        contribs.append(name)
        
        needchange = False
        # For each name, check if the account exists on disk
        for name in contribs:
            if not name.lower() in AU:
                # I makes sure we only print this once, and only if need be
                i += 1
                if i == 1:
                    print("")
                    print("%s ContributorsGroup missing accounts:" % wiki)
                print("   %s" % name)
                needchange = True
            else:
                # If still active, append to list of names to put in the new list
                actives.append(name)
                
        # Do we need to write a new group file?
        if len(actives) > 0 and afile and needchange:
            print("Making new, pruned, contributors group file for %s" % wiki)
            
            # Make a backup copy first
            with open(afile, "r") as f:
                d = f.read()
                f.close()
            with open(afile + ".old", "w") as f:
                f.write(d)
                f.close()
                
            # Write the new group file
            with open(afile, "w") as f:
                f.write("""#acl AdminGroup:read,write,admin,revert,delete All:read
'''Contributors''' with permission to edit the General wiki - read, write, delete and revert pages or individual changes.

Related: [[AdminGroup| Administrators]] with permission to grant privileges to Contributors, in addition to being Contributors themselves.
NOTE: This list is not publicly viewable.

""")
                for name in actives:
                    f.write(" * %s\r\n" % name)
                f.write("\r\n")
                f.close()
    
    
    # AdminGroup - same as before
    contribs = []
    afile = None
    if os.path.exists("%s/%s/data/pages/AdminGroup/current" % (args.data, wiki)):
        i = 0
        if os.path.isdir("%s/%s/data/pages/AdminGroup/revisions/" % (args.data, wiki)):
            rv = files("%s/%s/data/pages/AdminGroup/revisions/" % (args.data, wiki))
            lastfile = sorted(rv)[-1]
            afile = "%s/%s/data/pages/AdminGroup/revisions/%s" % (args.data, wiki, lastfile)
            with open(afile) as f:
                d = f.read()
                for match in re.finditer(r"\s*\*\s+\[*([^\r\n\]]+)", d):
                    name = match.group(1)
                    if name.lower() != "admingroup":
                        contribs.append(name)
        
        actives = []
        needchange = False
        for name in contribs:
            if not name.lower() in AU:
                i += 1
                if i == 1:
                    print("")
                    print("%s AdminGroup missing accounts:" % wiki)
                print("   %s" % name)
                needchange = True
            else:
                actives.append(name)


        if len(actives) > 0 and afile and needchange:
            print("Making new, pruned, admin group file for %s" % wiki)
            with open(afile, "r") as f:
                d = f.read()
                f.close()
            with open(afile + ".old", "w") as f:
                f.write(d)
                f.close()
            # Note the -All here, as opposed to All in contrib group (this is secret)
            with open(afile, "w") as f:
                f.write("""#acl AdminGroup:read,write,admin,revert,delete -All:read
This is a list of people who can do editing of the LocalBadContent and ContributorsGroup pages:

""")
                for name in actives:
                    f.write(" * %s\r\n" % name)
                f.write("\r\n")
                f.close()


        
