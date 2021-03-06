/*
 * Copyright 2009 Denys Pavlov, Igor Azarnyi
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

package org.yes.cart.service.federation.impl;

import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.yes.cart.domain.dto.ShopDTO;
import org.yes.cart.service.dto.ManagementService;
import org.yes.cart.service.federation.ShopFederationStrategy;

import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * User: denispavlov
 * Date: 16/09/2014
 * Time: 14:32
 */
public class ShopFederationStrategyImpl implements ShopFederationStrategy {

    private final ManagementService managementService;

    private final Cache USER_ACCESS_CACHE_ADMIN;
    private final Cache USER_ACCESS_CACHE_SHOP;
    private final Cache USER_ACCESS_CACHE_SHOP_ID;
    private final Cache USER_ACCESS_CACHE_SHOP_CODE;


    public ShopFederationStrategyImpl(final ManagementService managementService,
                                      final CacheManager cacheManager) {
        this.managementService = managementService;
        USER_ACCESS_CACHE_ADMIN = cacheManager.getCache("shopFederationStrategy-admin");
        USER_ACCESS_CACHE_SHOP = cacheManager.getCache("shopFederationStrategy-shop");
        USER_ACCESS_CACHE_SHOP_ID = cacheManager.getCache("shopFederationStrategy-shopId");
        USER_ACCESS_CACHE_SHOP_CODE = cacheManager.getCache("shopFederationStrategy-shopCode");
    }


    /**
     * {@inheritDoc}
     */
    @Override
    public boolean isCurrentUserSystemAdmin() {
        return isCurrentUser("ROLE_SMADMIN");
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean isCurrentUser(final String role) {
        if (SecurityContextHolder.getContext() == null || SecurityContextHolder.getContext().getAuthentication() == null) {
            return false;
        }
        final String currentManager = SecurityContextHolder.getContext().getAuthentication().getName();
        final String cacheKey = currentManager + role;
        Boolean isAdmin = getValueWrapper(USER_ACCESS_CACHE_ADMIN.get(cacheKey));
        if (isAdmin == null) {
            isAdmin = false;
            for (final GrantedAuthority auth : SecurityContextHolder.getContext().getAuthentication().getAuthorities()) {
                if (role.equals(auth.getAuthority())) {
                    isAdmin = true;
                    break;
                }
            }
            USER_ACCESS_CACHE_ADMIN.put(cacheKey, isAdmin);
        }
        return isAdmin;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean isShopAccessibleByCurrentManager(final String shopCode) {
        if (isCurrentUserSystemAdmin()) {
            return true;
        }
        final Set<String> currentAssigned = getAccessibleShopCodesByCurrentManager();
        return currentAssigned.contains(shopCode);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean isShopAccessibleByCurrentManager(final Long shopId) {
        if (isCurrentUserSystemAdmin()) {
            return true;
        }
        final Set<Long> currentAssigned = getAccessibleShopIdsByCurrentManager();
        return currentAssigned.contains(shopId);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Set<Long> getAccessibleShopIdsByCurrentManager() {
        if (SecurityContextHolder.getContext() == null || SecurityContextHolder.getContext().getAuthentication() == null) {
            return Collections.emptySet();
        }
        final String currentManager = SecurityContextHolder.getContext().getAuthentication().getName();
        Set<Long> currentAssignedIds = getValueWrapper(USER_ACCESS_CACHE_SHOP_ID.get(currentManager));
        if (currentAssignedIds == null) {
            try {
                final List<ShopDTO> currentAssigned = getAccessibleShopsByCurrentManager();
                final Set<Long> tmpCurrentAssignedIds = new HashSet<>();
                for (final ShopDTO shop : currentAssigned) {
                    tmpCurrentAssignedIds.add(shop.getShopId());
                }
                currentAssignedIds = Collections.unmodifiableSet(tmpCurrentAssignedIds);
            } catch (Exception exp) {
                currentAssignedIds = Collections.emptySet();
            }
        }
        return currentAssignedIds;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Set<String> getAccessibleShopCodesByCurrentManager() {
        if (SecurityContextHolder.getContext() == null || SecurityContextHolder.getContext().getAuthentication() == null) {
            return Collections.emptySet();
        }
        final String currentManager = SecurityContextHolder.getContext().getAuthentication().getName();
        Set<String> currentAssignedCodes = getValueWrapper(USER_ACCESS_CACHE_SHOP_CODE.get(currentManager));
        if (currentAssignedCodes == null) {
            try {
                final List<ShopDTO> currentAssigned = getAccessibleShopsByCurrentManager();
                final Set<String> tmpCurrentAssignedCodes = new HashSet<>();
                for (final ShopDTO shop : currentAssigned) {
                    tmpCurrentAssignedCodes.add(shop.getCode());
                }
                currentAssignedCodes = Collections.unmodifiableSet(tmpCurrentAssignedCodes);
            } catch (Exception exp) {
                currentAssignedCodes = Collections.emptySet();
            }
            USER_ACCESS_CACHE_SHOP_CODE.put(currentManager, currentAssignedCodes);
        }
        return currentAssignedCodes;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public List<ShopDTO> getAccessibleShopsByCurrentManager() {

        final String currentManager = SecurityContextHolder.getContext().getAuthentication().getName();
        return getAccessibleShopsByManager(currentManager);

    }


    private List<ShopDTO> getAccessibleShopsByManager(final String manager) {

        List<ShopDTO> shops = getValueWrapper(USER_ACCESS_CACHE_SHOP.get(manager));
        if (shops == null) {
            try {
                shops = Collections.unmodifiableList(managementService.getAssignedManagerShops(manager, true));
            } catch (Exception exp) {
                shops = Collections.emptyList();
            }
            USER_ACCESS_CACHE_SHOP.put(manager, shops);
        }
        return shops;
    }


    /**
     * {@inheritDoc}
     */
    @Override
    public boolean isEmployeeManageableByCurrentManager(final String employeeId) {

        final List<ShopDTO> employeeShops = getAccessibleShopsByManager(employeeId);
        final Set<Long> currentManager = getAccessibleShopIdsByCurrentManager();
        for (final ShopDTO employeeShop : employeeShops) {
            if (currentManager.contains(employeeShop.getShopId())) {
                /*
                    If this manager has access to top level shop to which employee has access to
                    OR this manager also has access to master shop of this employees sub.
                    This means: master shop managers can manage sub manager but sub manager cannot
                    manage master shop managers (or other sub managers).
                 */
                if (employeeShop.getMasterId() == null || currentManager.contains(employeeShop.getMasterId())) {
                    return true;
                }
            }
        }
        return false;
    }

    private <T> T getValueWrapper(final Cache.ValueWrapper wrapper) {
        if (wrapper != null) {
            return (T) wrapper.get();
        }
        return null;
    }



}
