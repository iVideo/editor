//
//  dialog.h
//  dialogueEditor
//
//  Created by yiplee on 13-8-23.
//  Copyright (c) 2013年 USTB. All rights reserved.
//

#ifndef dialogueEditor_dialog_h
#define dialogueEditor_dialog_h

enum DIALOG_TYPE {
	DIALOG_TYPE_VIDEO = 0,
	DIALOG_TYPE_IMAGE = 1,
};

static char *const videoFilePrefix = "video";
static char *const imageFilePrefix = "scene";
static char *const dialogInfoFile  = "info.plist";

#endif
