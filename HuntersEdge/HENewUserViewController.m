//
//  HENewUserViewController.m
//  Hunter's Edge
//
//  Created by James Forkey on 2/1/12.
//  Copyright (c) 2013 HF Development. All rights reserved.
//

#import "HENewUserViewController.h"

#import <Parse/Parse.h>
#import "HEActivityView.h"
#import "HEWallViewController.h"

@interface HENewUserViewController ()

- (void)processFieldEntries;
- (void)textInputChanged:(NSNotification *)note;
- (BOOL)shouldEnableDoneButton;

@end

@implementation HENewUserViewController

@synthesize doneButton;
@synthesize usernameField;
@synthesize passwordField, passwordAgainField;
@synthesize firstNameField, lastNameField;
@synthesize ageField;
@synthesize emailField;



#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:firstNameField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:lastNameField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:ageField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:emailField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:usernameField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:passwordField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:passwordAgainField];

	doneButton.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
	[usernameField becomeFirstResponder];
	[super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:usernameField];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:passwordField];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:passwordAgainField];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:firstNameField];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:lastNameField];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:ageField];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:emailField];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == usernameField) {
		[passwordField becomeFirstResponder];
	}
	if (textField == passwordField) {
		[passwordAgainField becomeFirstResponder];
	}
	if (textField == passwordAgainField) {
		[passwordAgainField resignFirstResponder];
		[self processFieldEntries];
	}

	return YES;
}

#pragma mark - ()

- (BOOL)shouldEnableDoneButton {
	BOOL enableDoneButton = NO;
	if (usernameField.text != nil &&
		usernameField.text.length > 0 &&
		passwordField.text != nil &&
		passwordField.text.length > 0 &&
		passwordAgainField.text != nil &&
		passwordAgainField.text.length > 0 &&
		lastNameField.text != nil &&
		lastNameField.text.length > 0 &&
		firstNameField.text != nil &&
		firstNameField.text.length > 0 &&
		ageField.text != nil &&
		ageField.text.length > 0 &&
		emailField.text != nil &&
		emailField.text.length > 0
		) {
		enableDoneButton = YES;
	}
	return enableDoneButton;
}

- (void)textInputChanged:(NSNotification *)note {
	doneButton.enabled = [self shouldEnableDoneButton];
}

- (IBAction)cancel:(id)sender {
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
	[usernameField resignFirstResponder];
	[passwordField resignFirstResponder];
	[passwordAgainField resignFirstResponder];
	[emailField resignFirstResponder];
	[ageField resignFirstResponder];
	[firstNameField resignFirstResponder];
	[lastNameField resignFirstResponder];
	[self processFieldEntries];
}

- (void)processFieldEntries {
	// Check that we have a non-zero username and passwords.
	// Compare password and passwordAgain for equality
	// Throw up a dialog that tells them what they did wrong if they did it wrong.
	NSString *firstName = firstNameField.text;
	NSString *lastName = lastNameField.text;
	NSString *age = ageField.text;
	NSString *email = emailField.text;
	NSString *username = usernameField.text;
	NSString *password = passwordField.text;
	NSString *passwordAgain = passwordAgainField.text;
	NSString *errorText = @"Please ";
	NSString *usernameBlankText = @"enter a username";
	NSString *passwordBlankText = @"enter a password";
	NSString *joinText = @", and ";
	NSString *passwordMismatchText = @"enter the same password twice";

	BOOL textError = NO;

	// Messaging nil will return 0, so these checks implicitly check for nil text.
	if (username.length == 0 || password.length == 0 || passwordAgain.length == 0) {
		textError = YES;

		// Set up the keyboard for the first field missing input:
		if (passwordAgain.length == 0) {
			[passwordAgainField becomeFirstResponder];
		}
		if (password.length == 0) {
			[passwordField becomeFirstResponder];
		}
		if (username.length == 0) {
			[usernameField becomeFirstResponder];
		}

		if (username.length == 0) {
			errorText = [errorText stringByAppendingString:usernameBlankText];
		}
		
		if (email.length == 0) {
			[emailField becomeFirstResponder];
		}
		if(email.length){
			errorText = [errorText stringByAppendingFormat:@"Please enter an Email address."];
		}
		if(firstName.length == 0){
			[firstNameField becomeFirstResponder];
		}
		if(firstName.length == 0){
			errorText = [errorText stringByAppendingFormat:@"Please enter a first name."];
		}
		if(lastName.length == 0) {
			[lastNameField becomeFirstResponder];
			errorText = [errorText stringByAppendingFormat:@"Please enter a last name."];
		}

		if (password.length == 0 || passwordAgain.length == 0) {
			if (username.length == 0) { // We need some joining text in the error:
				errorText = [errorText stringByAppendingString:joinText];
			}
			errorText = [errorText stringByAppendingString:passwordBlankText];
		}
	} else if ([password compare:passwordAgain] != NSOrderedSame) {
		// We have non-zero strings.
		// Check for equal password strings.
		textError = YES;
		errorText = [errorText stringByAppendingString:passwordMismatchText];
		[passwordField becomeFirstResponder];
	}

	if (textError) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorText message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
		[alertView show];
		return;
	}

	// Everything looks good; try to log in.
	// Disable the done button for now.
	doneButton.enabled = NO;
	HEActivityView *activityView = [[HEActivityView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
	UILabel *label = activityView.label;
	label.text = @"Signing You Up";
	label.font = [UIFont boldSystemFontOfSize:20.f];
	[activityView.activityIndicator startAnimating];
	[activityView layoutSubviews];

	[self.view addSubview:activityView];

	// Call into an object somewhere that has code for setting up a user.
	// The app delegate cares about this, but so do a lot of other objects.
	// For now, do this inline.

	PFUser *user = [PFUser user];
	user.username = username;
	user.password = password;
	user.email = email;
	
	[user setObject:firstName forKey:@"firstName"];
	[user setObject:lastName forKey:@"lastName"];

	[user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		if (error) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			[alertView show];
			doneButton.enabled = [self shouldEnableDoneButton];
			[activityView.activityIndicator stopAnimating];
			[activityView removeFromSuperview];
			// Bring the keyboard back up, because they'll probably need to change something.
			[usernameField becomeFirstResponder];
			return;
		}

		// Success!
		[activityView.activityIndicator stopAnimating];
		[activityView removeFromSuperview];

		HEWallViewController *wallViewController = [[HEWallViewController alloc] initWithNibName:nil bundle:nil];
		[(UINavigationController *)self.presentingViewController pushViewController:wallViewController animated:NO];
		[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
	}];
}

@end
