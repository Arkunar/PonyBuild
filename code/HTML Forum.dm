var/ID_Number = 0
var/Forum_ID_Number = 0
mob/var/tmp/obj/Forums/Forum/Selected_Forum = null

proc
	save_ID()
		var/filename = "Forum/Forum_IDs.sav"
		var/savefile/F = new(filename)
		var/directory = "/Forum/Forum/"
		F.cd = directory
		F["ID"] << ID_Number
		F["Forum_ID"] << Forum_ID_Number
	load_ID()
		if(length(file2text("Forum/Forum_IDs.sav")))
			var/filename = "Forum/Forum_IDs.sav"
			var/savefile/F = new(filename)
			F.cd = "/Forum/Forum/"
			F["ID"] >> ID_Number
			F["Forum_ID"] >> Forum_ID_Number
			if(ID_Number == null)
				ID_Number = 0
			if(Forum_ID_Number == null)
				Forum_ID_Number = 0


mob/proc/Display_HTML_Forum()
	var/obj/Forums/Forum/F = src.Selected_Forum
	src << browse_rsc('Closed Thread.dmi',"TheX")
	src << browse_rsc('New Topic.jpg',"NewTopic")
	if(!Forum_Banned.Find("[key]"))
		var/HTML = "<html><body bgcolor=#608590>"
		var/list/Forum_List = list()
		for(var/obj/Forums/Forum/Fg in world)
			if(Fg.Valid_Forum2 == 1)
				Forum_List += Fg
		var/Numbero = 0
		HTML += "<center>"
		for(var/obj/Forums/Forum/Fg in Forum_List)
			if(Forum_List.len > 1)
				Numbero++
				if(Numbero == 1)
					HTML += "<a href='?reference=ViewForum;forum=[Fg.MyForum_ID]'>[Fg.name]</a>  -"
				else if(Numbero < Forum_List.len)
					HTML += "  <a href='?reference=ViewForum;forum=[Fg.MyForum_ID]'>[Fg.name]</a>  -"
				else
					HTML += "  <a href='?reference=ViewForum;forum=[Fg.MyForum_ID]'>[Fg.name]</a>"
			else
				if(Forum_List.len == 1)
					HTML += "<a href='?reference=ViewForum;forum=[Fg.MyForum_ID]'>[Fg.name]</a>"
		HTML += "</center><br><br><center><b><font size = +2>[F.name]</font></b><br>[F.desc]</center><br><table cellspacing=20 width = 100%  border=0>"
		if(Forum_Page[F.name] == 0||Forum_Page[F.name] == null)
			Forum_Page[F.name] = 1
		var/max_pages = F.Forum_Threads.len/10
		var/end = Forum_Page[F.name]*10
		var/start = end-10
		if(start < 0)
			start = 0
		var/list/list_duplicate = new/list()
		for(var/T=length(F.Forum_Threads);T>0;T--)
			if(F.Forum_Threads[T] != null)
				list_duplicate+=F.Forum_Threads[T]
			else
				F.Forum_Threads -= F.Forum_Threads[T]
		if(Administrator_Keys.Find(src.key))
			HTML += "<tr><td  valign=middle><a href='?reference=Admin;forum=[F.MyForum_ID]'><font color = #F50000>Moderator Commands \[*\]</font></a></td></tr><tr>"
		if(Forum_Page[F.name] < max_pages)
			HTML += "<tr><td><a href='?reference=Next;forum=[F.MyForum_ID]'>Next  -></a></td></tr><tr><td> </td></tr>"
		HTML += "</table><table bgcolor=#CCCCFC cellpadding=15 width = 100% border=0><tr><td><a href='?reference=NewThread;forum=[F.MyForum_ID]'><img src=NewTopic></a></td></tr><tr><td> </td></tr>"
		var/w = 0
		var/MyColor = 1
		for(var/obj/Forums/Forum/Thread/O in list_duplicate)
			if(O.MyID > 0)
				if(O.icon != 'Closed Thread.dmi')
					if(w >= start&&w < end)
						if(O.Message != "")
							if(MyColor == 1)
								MyColor = 0
								HTML += "<tr bgcolor=#CCCCF0>"
							else
								MyColor = 1
								HTML += "<tr bgcolor=#CCCCFF>"
							HTML += "<td><a href='?reference=Thread;messageID=[O.MyID];forum=[F.MyForum_ID]'>[O.name]</a>"
							if(O.Forum_Messages.len == 1)
								HTML += "        [O.Forum_Messages.len] reply"
							else
								HTML += "        [O.Forum_Messages.len] replies"
							w++
							HTML += "</td><td align=right valign=middle><b><font color = #707070>Author:  </font></b><font color = #4040CC>[O.suffix]</font></td></tr>"
						else
							F.Forum_Threads -= O
					else if(w < end&&w < start)
						w++
					else
						if(w > end)
							break
				else
					if(w >= start&&w < end)
						if(O.Message != "")
							if(MyColor == 1)
								MyColor = 0
								HTML += "<tr bgcolor=#CCCCF0>"
							else
								MyColor = 1
								HTML += "<tr bgcolor=#CCCCFF>"
							HTML += "<td valign=middle><img src=TheX><a href='?reference=Thread;messageID=[O.MyID];forum=[F.MyForum_ID]'>[O.name]</a>"
							if(O.Forum_Messages.len == 1)
								HTML += "        [O.Forum_Messages.len] reply"
							else
								HTML += "        [O.Forum_Messages.len] replies"
							w++
							HTML += "</td><td align=right valign=middle><b><font color = #707070>Author:  </font></b><font color = #4040CC>[O.suffix]</font></td></tr>"
						else
							F.Forum_Threads -= O
					else if(w < end&&w < start)
						w++
					else
						if(w > end)
							break
		if(Forum_Page[F.name] > 1)
			HTML += "</table><table cellspacing=20 width = 100%  border=0><tr><td> </td></tr>"
			HTML += "<tr><td><a href='?reference=Prev;forum=[F.MyForum_ID]'><-  Previous</a></td></tr>"
		HTML += "</table></body></html>"
		src << browse(HTML)
	else
		stat("You are banned from the [world.name] forums.")


client/Topic(href,href_list[])
	switch(href_list["reference"])
		if("ViewForum")
			var/obj/Forums/Forum/F
			for(var/obj/Forums/Forum/FF in world)
				if(text2num(href_list["forum"]) == FF.MyForum_ID)
					F = FF
					break
			if(F != null)
				mob.Selected_Forum = F
				mob.Display_HTML_Forum(mob.Selected_Forum)
		if("Admin")
			var/obj/Forums/Forum/F
			for(var/obj/Forums/Forum/FF in world)
				if(text2num(href_list["forum"]) == FF.MyForum_ID)
					F = FF
					break
			if(F != null)
				F.Forum_Admin.Click()
		if("Next")
			var/obj/Forums/Forum/F
			for(var/obj/Forums/Forum/FF in world)
				if(text2num(href_list["forum"]) == FF.MyForum_ID)
					F = FF
					break
			if(F != null)
				F.Forum_Next.Click()
		if("Prev")
			var/obj/Forums/Forum/F
			for(var/obj/Forums/Forum/FF in world)
				if(text2num(href_list["forum"]) == FF.MyForum_ID)
					F = FF
					break
			if(F != null)
				F.Forum_Prev.Click()
		if("Reply")
			var/obj/Forums/Forum/F
			for(var/obj/Forums/Forum/FF in world)
				if(text2num(href_list["forum"]) == FF.MyForum_ID)
					F = FF
					break
			if(F != null)
				F.Forum_Reply.Click()
		if("NewThread")
			var/obj/Forums/Forum/F
			for(var/obj/Forums/Forum/FF in world)
				if(text2num(href_list["forum"]) == FF.MyForum_ID)
					F = FF
					break
			if(F != null)
				F.Forum_New_Thread.Click()
		if("Back")
			var/obj/Forums/Forum/F
			for(var/obj/Forums/Forum/FF in world)
				if(text2num(href_list["forum"]) == FF.MyForum_ID)
					F = FF
					break
			if(F != null)
				mob.Display_HTML_Forum(F)
		if("Thread")
			var/obj/Forums/Forum/F
			for(var/obj/Forums/Forum/FF in world)
				if(text2num(href_list["forum"]) == FF.MyForum_ID)
					F = FF
					break
			if(F != null)
				var/obj/Forums/Forum/FFF
				for(var/obj/Forums/Forum/Thread/FFFF in world)
					if(text2num(href_list["messageID"]) == FFFF.MyID)
						FFF = FFFF
						break
				if(FFF != null)
					FFF.Click()
		if("DeleteThread")
			var/obj/Forums/Forum/F
			for(var/obj/Forums/Forum/FF in world)
				if(text2num(href_list["forum"]) == FF.MyForum_ID)
					F = FF
					break
			if(F != null)
				var/obj/Forums/Forum/Thread/FFF
				for(var/obj/Forums/Forum/Thread/FFFF in world)
					if(text2num(href_list["messageID"]) == FFFF.MyID)
						FFF = FFFF
						break
				if(FFF != null)
					FFF.Delete_Message2()
		if("DeleteMessage")
			var/obj/Forums/Forum/F
			for(var/obj/Forums/Forum/FF in world)
				if(text2num(href_list["forum"]) == FF.MyForum_ID)
					F = FF
					break
			if(F != null)
				var/obj/Forums/Forum/Message/FFF
				for(var/obj/Forums/Forum/Message/FFFF in world)
					if(text2num(href_list["messageID"]) == FFFF.MyID)
						FFF = FFFF
						break
				if(FFF != null)
					FFF.Delete_Message2()
		if("CloseThread")
			var/obj/Forums/Forum/F
			for(var/obj/Forums/Forum/FF in world)
				if(text2num(href_list["forum"]) == FF.MyForum_ID)
					F = FF
					break
			if(F != null)
				F.Forum_Close_Thread.Click()
	..()







mob/proc/AdminCheckThread(var/obj/Forums/Forum/Foo,var/obj/Forums/Forum/Thread/ohm)
	src << browse_rsc('Delete Thread.jpg',"DeleteThreader")
	var/HTML = "<a href='?reference=DeleteThread;forum=[Foo.MyForum_ID];messageID=[ohm.MyID]'><img src=DeleteThreader align=middle></a>"
	if(Administrator_Keys.Find(src.key))
		return HTML
	else
		return "<br>"

mob/proc/AdminCheckThread2(var/obj/Forums/Forum/Fooo,var/obj/Forums/Forum/Thread/ohm2)
	src << browse_rsc('closethread.jpg',"CloseThreader")
	var/HTML = "<a href='?reference=CloseThread;forum=[Fooo.MyForum_ID];messageID=[ohm2.MyID]'><img src=CloseThreader align=middle></a>"
	if(Administrator_Keys.Find(src.key)&&ohm2.icon != 'Closed Thread.dmi')
		return HTML
	else
		return ""

mob/proc/AdminCheckMessage(var/obj/Forums/Forum/Foooo,var/obj/Forums/Forum/Message/ohm3)
	src << browse_rsc('Delete Message.jpg',"DeleteMessager")
	var/HTML = "<a href='?reference=DeleteMessage;forum=[Foooo.MyForum_ID];messageID=[ohm3.MyID]'><img src=DeleteMessager align=middle></a>"
	if(Administrator_Keys.Find(src.key))
		return HTML
	else
		return "<br>"

mob/proc/ReplyCheckClosed(var/obj/Forums/Forum/Fooooo)
	src << browse_rsc('Reply.jpg',"Replyer")
	var/HTML = "<a href='?reference=Reply;forum=[Fooooo.MyForum_ID]'><img src=Replyer align=middle></a>"
	if(src.Forum_Thread.icon != 'Closed Thread.dmi')
		return HTML
	else
		return "<br>"








