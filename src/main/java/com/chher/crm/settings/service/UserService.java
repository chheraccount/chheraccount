package com.chher.crm.settings.service;

import com.chher.crm.settings.domain.User;
import com.chher.crm.exception.LoginException;

import java.util.List;

public interface UserService {

    User login(String loginAct, String loginPwd, String ip) throws LoginException;

    List<User> getUserList();

}
