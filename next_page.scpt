-- © Copyright 2005, Red Sweater Software. All Rights Reserved.
-- Permission to copy granted for personal use only. All copies of this script
-- must retain this copyright information and all lines of comments below, up to
-- and including the line indicating "End of Red Sweater Comments". 
--
-- Any commercial use of this code must be licensed from the Copyright
-- owner, Red Sweater Software.
--
-- A script to go to the next page of a multi-page web document/story/whatever.
-- The script works by by guessing the "next" URL link and changing the location
-- of the page to that link's target.
--
-- This script will work on many sites that I have not tested, because it 
-- searches for a number of "link names" that are commonly used by sites 
-- presenting multi-page results. If you come across some common link names 
-- that I have not included, please contact me so I can update the script for
-- all to benefit. http://www.red-sweater.com/
--
-- Version 1.0.9
--    Support <link rel="next"> values
--
-- Version 1.0.8
--	Support Flickr.com
--
-- Version 1.0.7
--	Support links named "forward" (e.g. easynews.com)
--
-- Version 1.0.6
--    Fix bug preventing Salon.com from working correctly.
--
-- Version 1.0.5:
--	Support any link starting with "Next" and ending in ">"
--
-- Version 1.0.4:
--	Support sites that put non-breaking spaces in their link text (e.g. photos.com)
--	
-- Version 1.0.3:
--	Support for graphical links named next.gif or next.jpg
--	
--	New sites tested:
--	ADC documentation - "Next Page >"
--
-- Version 1.0.2:
--	Lots of new sites supported by virtue of case insensitive comparisons. Some new special cases added.
--
--	New sites tested:
--	vBulletin - Contains a link named ">"
--	Wired! News - Contains a link whose "class" attribute is 'next'
--	Google Update - For some reason its link is now "\nNext"
--	Craiglist - Special case - any link that starts with "next " and ends in " postings"
--	tribe.net - link named "next"
--	friendster - link named "next >"
--	macdevcenter - link named "Next Page"
--	apple mailing lists - link named "Next >>"
--
-- Version 1.0.1:
--	arstechnica.com - Contains a link named "Next »" (option-shift-\)
--
-- Version 1.0:
--
--	a9.com - Contains a link named "Next"
--	cocoabuilder.com - Contains a link named ">>"
--	Google Search - Contains a link named "Next"
--	msn.com - Contains a link named "Next"
--	NYTimes.com - Contains a link named "Next>>"
--	Salon.com Stories - Contains a link containing a relatively higher "index' page.
--	WashingtonPost.com - Contains a link named "Next"
--	Yahoo Search - Contains a link named "Next"
--
-- End of Red Sweater Comments

tell application "Safari"
	activate
	set myJavaScript to "

function GetLinkWithImageNamed(theImageName, subStringOK)
{
	// For every link
	for (i=0; i<document.links.length; i++)
	{
		// For every child of that link
		for (j=0; j<document.links[i].children.length; j++)
		{
			// Is it an IMG tag?
			if (document.links[i].children[j].tagName.toLowerCase() == 'img')
			{
				var myImageSource = document.links[i].children[j].src;
				
				// Get the leaf of the path
				var pathLeafName = myImageSource.split('/').pop();
				
				// Does it match?
				var pathLower = pathLeafName.toLowerCase();
				var nameLower = theImageName.toLowerCase();
				if ((pathLower == nameLower) || (subStringOK && (pathLower.indexOf(nameLower) != -1)))
				{
					return i;
				}
			}
		}
	}
	return -1;
}

function GetLinkIndexNamed(theLinkName)
{
	for (i=0; i<document.links.length; i++)
	{
		var thisLinkContent = document.links[i].innerText;
			
		// Convert all non-breaking space to plain for matching
		thisLinkContent = thisLinkContent.replace(/\\xA0/g, ' ');

		// IS it the next link?
		if (thisLinkContent.toLowerCase() == theLinkName.toLowerCase())
		{		
			return i;
		}
	}
	return -1;
}

function GetLinkOfClass(theClassName)
{
	for (i=0; i<document.links.length; i++)
	{
		var thisLinkClass = document.links[i].attributes.getNamedItem('class');
		if (thisLinkClass)
		{
			// IS it the next link?
			if (thisLinkClass.value.toLowerCase() == theClassName.toLowerCase())
			{
				return i;
			}
		}
	}
	return -1;
}

function GetLinkWithRelTag(theRelTag)
{
	for (i=0; i<document.links.length; i++)
	{
		var thisLinkRelTag = document.links[i].attributes.getNamedItem('rel');
		if (thisLinkRelTag)
		{
			// IS it the next link?
			if (thisLinkRelTag.value.toLowerCase() == theRelTag.toLowerCase())
			{
				return i;
			}
		}
	}
	return -1;
}

function GetLinkWithPrefixAndSuffix(thePrefix, theSuffix)
{
	for (i=0; i<document.links.length; i++)
	{
		var thisLinkContent = document.links[i].innerText;
			
		// Convert all non-breaking space to plain for matching
		thisLinkContent = thisLinkContent.replace(/\\xA0/g, ' ');

		// IS it the right prefix?
		if (thisLinkContent.indexOf(thePrefix) == 0)
		{
			// And the right suffix?
			if (thisLinkContent.substring(thisLinkContent.length - theSuffix.length, thisLinkContent.length) == theSuffix)
			{
				return i;
			}
		}
	}
	return -1;
}

function SalonGetNextLink()
{
	// What is our current index number?
	var mySearchToken = '/index';
	var myURLString = document.location.toString();
	var thisIndexOffset = myURLString.indexOf(mySearchToken);
	var currentIndex = 0;
	if (thisIndexOffset != -1)
	{
		thisIndexOffset +=  mySearchToken.length;
		var indexString = myURLString.substring(thisIndexOffset, myURLString.length);
		currentIndex = parseInt(indexString);
		if (isNaN(currentIndex)) currentIndex = 0;
	}

	// Ok - the next link will be numerically higher than current. Find a link suitably 
	// identified.
	var newIndex = currentIndex + 1;
	var newString = mySearchToken + newIndex;
	alert(newString);
	for (i=0; i<document.links.length; i++)
	{
		var thisLinkContent = document.links[i].toString();
		// IS it the next link?
		if (thisLinkContent.indexOf(newString) != -1)
		{
			return i;
		}	
	}
	return -1;
}

var foundLinkIndex = -1;

// First, check to see if it's a particular domain that 
// we have special rules for handling...
if (document.location.toString().indexOf('salon.com') != -1)
{
	foundLinkIndex = SalonGetNextLink();
}
else if (document.location.toString().indexOf('craigslist.org') != -1)
{
	foundLinkIndex = GetLinkWithPrefixAndSuffix('next ', ' postings')
}
else if (document.location.toString().indexOf('flickr.com') != -1)
{
	// Flickr makes it hard
	foundLinkIndex = GetLinkWithImageNamed('Next', true);
}

if (foundLinkIndex == -1)
{
	// Try by class ID
	foundLinkIndex = GetLinkOfClass('next');

	// Try for any link with a rel=next tag
	foundLinkIndex = GetLinkWithRelTag('next');

	// Try a bunch of common link names 
	if (foundLinkIndex == -1)
	{
		foundLinkIndex = GetLinkIndexNamed('Next');	
	}
	if (foundLinkIndex == -1)
	{
		foundLinkIndex = GetLinkIndexNamed('\\nNext');	
	}
	if (foundLinkIndex == -1)
	{
		foundLinkIndex = GetLinkIndexNamed('>>');
	}
	if (foundLinkIndex == -1)
	{
		foundLinkIndex = GetLinkIndexNamed('>');
	}
	if (foundLinkIndex == -1)
	{
		foundLinkIndex = GetLinkWithPrefixAndSuffix('Next Page', '');
	}
	if (foundLinkIndex == -1)
	{
		foundLinkIndex = GetLinkWithPrefixAndSuffix('Next', '>');
	}	
	if (foundLinkIndex == -1)
	{
		foundLinkIndex = GetLinkWithPrefixAndSuffix('Next', '»');
	}		
	if (foundLinkIndex == -1)
	{
		foundLinkIndex = GetLinkWithImageNamed('next.jpg');
	}
	if (foundLinkIndex == -1)
	{
		foundLinkIndex = GetLinkWithImageNamed('next.gif');
	}
	if (foundLinkIndex == -1)
	{
		foundLinkIndex = GetLinkIndexNamed('forward');
	}	
}

if (foundLinkIndex == -1)
{
	alert('Sorry, I could not find the next page of results for this page.');
}
else
{
	document.location=document.links[foundLinkIndex];
}

"
	do JavaScript myJavaScript in document 1
end tell

