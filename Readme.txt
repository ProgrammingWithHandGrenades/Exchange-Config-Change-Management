This is a basic framework for creating a repository of exported organization level objects for an Exchange 2010 installation, and comparing two export sets to find the changes.

Currently it only reports changes.  I haven't quite decided how I want to report new and deleted objects, but it performs the basic function of creating the repository, and reporting on changes between exported sets of configuration objects.  

It's designed to be very generic, and may be portable to other systems.  The only requirement is that the objects being exported have a Get-* cmdlet, and GUID and Identity properties.  

All properties are cast as [string] before comparison to unroll arraylists. It was created for change management and diagnostic research when troubleshooting Exchange issues that may be caused by configuration changes. All of the multi-valued properties of the objects involved are arraylists, and so far that method has proved to be reliable for detecting changes.  

The compare script takes the full path of two export sets as arguments.  Order is irrelevant, it will always consider the oldest set the reference set, and the newest set the difference set.

The included select-exportsets is a simple script that I use for testing that allows you to select two export sets from a gridview for comparison.

I'll be adding more later, but for now there should be enough to build on if anyone's interested in using it for their own Exchange organization or trying to port it to other systems.